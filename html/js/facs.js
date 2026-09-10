var BASE_URL = 'https://id.acdh.oeaw.ac.at/kalbeck-tagebuch/';
var FACS_FILE_ENDING = '.tif?format=image%2Fwebp&param=full/full/0/default.jpg';

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
    viewer.viewport.fitHorizontally(true);

    var bounds = viewer.viewport.getBounds(true);
    var contentBounds = viewer.world.getHomeBounds();

    viewer.viewport.panTo(
        new OpenSeadragon.Point(
            bounds.x + (bounds.width / 2),
            contentBounds.y + (bounds.height / 2)
        ),
        true
    );
    viewer.viewport.applyConstraints();
}

viewer.addHandler('open', alignImageToTop);
// Partition the editorial text into per-facsimile segments using the
// generated <span class="pb"> markers and show only the segment for
// the currently visible image in the OpenSeadragon viewer.
function partitionTextByPB() {
    var pbElements = Array.from(document.querySelectorAll('.pb'));
    if (!pbElements.length) return [];

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

    return Array.from(container.querySelectorAll('.facs-text-segment'));
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
    var segments = partitionTextByPB();
    // initial hide/show after viewer opens
    viewer.addHandler('open', function() {
        // align image then update text
        alignImageToTop();
        updateVisibleText(segments);
    });
    viewer.addHandler('page', function() {
        updateVisibleText(segments);
    });
    // fallback: update once immediately if viewer already opened
    setTimeout(function() { updateVisibleText(segments); }, 250);
});