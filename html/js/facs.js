var BASE_URL = 'https://id.acdh.oeaw.ac.at/kalbeck-tagebuch/';
var FACS_FILE_ENDING = '.tif?format=image%2Fwebp&param=full/full/0/default.jpg';
var initialPageIndex = null;
var suppressUrlSync = false;

function parsePageIndexFromLocation() {
    var searchParams = new URLSearchParams(window.location.search);
    var candidates = [
        searchParams.get('page'),
        searchParams.get('p'),
        searchParams.get('facs'),
        window.location.hash.replace(/^#/, '')
    ];

    for (var i = 0; i < candidates.length; i++) {
        var value = candidates[i];
        if (!value) continue;

        var match = value.match(/^(?:p|page|facs)-?(\d+)$/i);
        var pageNumber = match ? parseInt(match[1], 10) : parseInt(value, 10);

        if (!Number.isNaN(pageNumber) && pageNumber > 0) {
            return pageNumber - 1;
        }
    }

    return null;
}

function syncUrlToPage(pageIndex) {
    if (suppressUrlSync) return;

    var nextHash = '#p-' + (pageIndex + 1);
    var nextUrl = window.location.pathname + window.location.search + nextHash;
    if (window.location.hash !== nextHash) {
        window.history.replaceState(null, '', nextUrl);
    }
}

function goToPageFromLocation() {
    if (initialPageIndex === null || typeof viewer.goToPage !== 'function') return;

    var lastPageIndex = tileSources.length - 1;
    if (lastPageIndex < 0) return;

    var targetPageIndex = Math.min(initialPageIndex, lastPageIndex);
    suppressUrlSync = true;
    viewer.goToPage(targetPageIndex);
    suppressUrlSync = false;
}

var tileSources = Array.from(
    document.querySelectorAll('#facsContainer .facsId[data-facs-name]'),
    function (element) {
        return {
            type: 'image',
            url: `${BASE_URL}${element.dataset.facsName}${FACS_FILE_ENDING}`
        };
    }
);

var viewer = OpenSeadragon({
    id: "osdViewer",
    showRotationControl: true,
    gestureSettingsTouch: {
        pinchRotate: true
    },
    sequenceMode: true,
    showReferenceStrip: true,
    tileSources: tileSources,
    prefixUrl: "vendor/openseadragon-bin-4.1.1/images/",
});

function alignImageToTop() {
    viewer.viewport.goHome(true);
}

var facsSegments = [];
initialPageIndex = parsePageIndexFromLocation();

viewer.addHandler('open', function() {
    alignImageToTop();
    goToPageFromLocation();
    updateVisibleText(facsSegments);
});
// Partition the editorial text into per-facsimile segments using the
// generated <span class="pb"> markers and show only the segment for
// the currently visible image in the OpenSeadragon viewer.
function partitionTextByPB() {
    var pbElements = Array.from(document.querySelectorAll('.pb'));
    if (!pbElements.length) return [];

    // compute document order for pb markers and footnotes BEFORE we move nodes
    var pbOrder = new Map();
    var footnoteOrder = new Map();
    var order = 0;
    var walker = document.createTreeWalker(document.body, NodeFilter.SHOW_ELEMENT, null, false);
    while (walker.nextNode()) {
        order++;
        var el = walker.currentNode;
        if (el.classList && el.classList.contains('pb')) {
            pbOrder.set(el, order);
        }
        if (el.classList && el.classList.contains('footnotes')) {
            footnoteOrder.set(el, order);
        }
    }

    var container = pbElements[0].parentNode;
    var childNodes = Array.from(container.childNodes);
    var segIndex = 0;
    var currentSeg = null;

    childNodes.forEach(function(node) {
        if (node.nodeType === Node.ELEMENT_NODE && node.classList.contains('pb')) {
            // start a new segment and move the pb marker into it
            segIndex++;
            currentSeg = document.createElement('div');
            currentSeg.className = 'facs-text-segment';
            currentSeg.setAttribute('data-facs-index', segIndex);
            container.insertBefore(currentSeg, node);
            currentSeg.appendChild(node);
            return;
        }
        if (currentSeg) {
            currentSeg.appendChild(node);
        }
    });

    var segments = Array.from(container.querySelectorAll('.facs-text-segment'));

    // Attach each footnote to the segment that contains its note call.
    var footnotes = Array.from(document.querySelectorAll('.footnotes'));
    footnotes.forEach(function(fn) {
        var targetSeg = null;
        var noteCall = fn.querySelector('a[href^="#fna_"]');

        if (noteCall) {
            var targetId = noteCall.getAttribute('href').slice(1);
            var noteCallAnchor = document.querySelector('a[name="' + targetId + '"]');
            while (noteCallAnchor && !targetSeg) {
                if (noteCallAnchor.classList && noteCallAnchor.classList.contains('facs-text-segment')) {
                    targetSeg = noteCallAnchor;
                } else {
                    noteCallAnchor = noteCallAnchor.parentNode;
                }
            }
        }

        if (!targetSeg) {
            var fnOrder = footnoteOrder.get(fn);
            if (!fnOrder) return;
            var preceding = 0;
            pbOrder.forEach(function(pbIdx) {
                if (pbIdx < fnOrder) preceding++;
            });
            var targetIndex = preceding || 1; // if none preceding, attach to first
            targetSeg = segments.find(function(s) { return parseInt(s.getAttribute('data-facs-index'), 10) === targetIndex; });
        }

        if (!targetSeg) targetSeg = segments[segments.length - 1];
        if (targetSeg && fn.parentNode !== targetSeg) {
            targetSeg.appendChild(fn);
        }
    });

    return segments;
}

function updateVisibleText(segments) {
    if (!segments || !segments.length) return;
    var pageIndex = 0;
    try {
        // viewer.currentPage() returns 0-based index when sequenceMode=true
        if (typeof viewer.currentPage === 'function') {
            pageIndex = viewer.currentPage();
        } else if (viewer.viewport && typeof viewer.viewport.getItemAt === 'function') {
            pageIndex = viewer.currentPage || 0;
        }
    } catch (e) {
        pageIndex = 0;
    }
    var visible = pageIndex + 1; // our segments are 1-based
    segments.forEach(function(el) {
        if (parseInt(el.getAttribute('data-facs-index'), 10) === visible) {
            el.style.display = '';
        } else {
            el.style.display = 'none';
        }
    });
}

// wire up partitioning and viewer events after DOM ready
document.addEventListener('DOMContentLoaded', function() {
    facsSegments = partitionTextByPB();
    viewer.addHandler('page', function() {
        syncUrlToPage(viewer.currentPage());
        updateVisibleText(facsSegments);
    });
    window.addEventListener('hashchange', function() {
        var pageIndex = parsePageIndexFromLocation();
        if (pageIndex === null || typeof viewer.goToPage !== 'function') return;

        var lastPageIndex = tileSources.length - 1;
        if (lastPageIndex < 0) return;

        suppressUrlSync = true;
        viewer.goToPage(Math.min(pageIndex, lastPageIndex));
        suppressUrlSync = false;
    });
    if (viewer.isOpen && viewer.isOpen()) {
        alignImageToTop();
        goToPageFromLocation();
        updateVisibleText(facsSegments);
    }
});                                                     
