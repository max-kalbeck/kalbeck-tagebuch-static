var BASE_URL = 'facs/';
var FACS_FILE_ENDING = '.jpg';

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