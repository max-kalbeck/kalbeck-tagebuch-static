function zoom_to_point_from_row_data(
  row_data,
  map,
  zoom,
  existing_markers_by_coordinates
) {
  let coordinate_key = get_coordinate_key_from_row_data(row_data);
  let marker = existing_markers_by_coordinates[coordinate_key];

  if (!marker) {
    return;
  }

  marker.openPopup();
  map.flyTo([row_data.lat, row_data.lng], zoom);
}

function get_coordinate_key_from_row_data(row_data) {
  return row_data.lat + row_data.lng;
}

/*rows_data is a list of DataTables row-data objects (see table_cfg in
map_table_cfg.js), keyed by the lowercased column headers*/
function init_map_from_rows(rows_data, markers) {
  console.log("populating map with icons");
  let existing_icons_by_coordinates = {};
  markers.clearLayers()
  rows_data.forEach((row_data) => {
    let coordinate_key = get_coordinate_key_from_row_data(row_data);
    var marker = L.marker(new L.LatLng(row_data.lat, row_data.lng), { title: get_tooltip_label(row_data) });
    marker.bindPopup(get_popup_label_string_html(row_data));
    markers.addLayer(marker);
    existing_icons_by_coordinates[coordinate_key] = marker;
  });
  return existing_icons_by_coordinates;
}

function toggle_marker_visibility(marker) {
  let opacity = marker.options.opacity;
  console.log(opacity)
  if (opacity === 1) {
    marker.setOpacity(0)
  } else {
    marker.setOpacity(1)
  }
}

/*builds the DataTable from table_cfg.table_div_html_id and keeps the map
markers in sync with it: markers are (re)built from every row that matches
the current search/filter (not just the current page), and clicking a row
(outside of its link) flies the map to that row's marker*/
function populateMapFromTable(map, on_row_click_zoom, markers, table_cfg) {
  let existing_markers_by_coordinates = {};

  function refreshMarkers(api) {
    const rows_data = api.rows({ search: 'applied' }).data().toArray();
    existing_markers_by_coordinates = init_map_from_rows(rows_data, markers);
  }

  initDataTable(table_cfg.table_div_html_id, {
    onInit: function (api) {
      console.log("built table");
      refreshMarkers(api);
      try {
        map.fitBounds(markers.getBounds());
      } catch (err) {
        console.log(err);
      }
    },
    onDraw: function (api) {
      refreshMarkers(api);
      map.fitBounds(markers.getBounds());
    },
    onRowClick: function (event, tr, api) {
      if (event.target.closest('a')) {
        return;
      }

      let row_data = api.row(tr).data();
      zoom_to_point_from_row_data(
        row_data,
        map,
        on_row_click_zoom,
        existing_markers_by_coordinates
      );
    }
  });
}

/////////////////////
// building the map//
/////////////////////
function build_map_and_table(map_cfg, table_cfg, wms_cfg = null, tms_cfg = null) {
  console.log("loading map");
  let map = L.map(map_cfg.div_id).setView(
    map_cfg.initial_coordinates,
    map_cfg.initial_zoom
  );
  let tile_layer = L.tileLayer(map_cfg.base_map_url, {
    maxZoom: map_cfg.max_zoom,
    minZoom: map_cfg.min_zoom,
    attribution: map_cfg.attribution,
  });
  var markers = L.markerClusterGroup();
  let overlay_control = {};
  overlay_control[map_cfg.base_map_label] = tile_layer

  // handle the layers
  // order of adding matters!
  tile_layer.addTo(map);
  // if wms_cfg is provided wms map layer gets added
  if (wms_cfg !== null) {
    // this is for the page gui / switch for toggling overlays
    let wms_layer = L.tileLayer.wms(wms_cfg.wms_url, wms_cfg.layerOptions);
    wms_layer.addTo(map);
    overlay_control[wms_cfg.label] = wms_layer;
  }

  // if tms_cfg is provided tms map layer gets added
  if (tms_cfg !== null) {
    // this is for the page gui / switch for toggling overlays
    let tms_layer = L.tileLayer('https://emt-project.github.io/mapserver/map_01/{z}/{x}/{y}.png', tms_cfg.layerOptions);
    tms_layer.addTo(map);
    overlay_control[tms_cfg.label] = tms_layer;
  }
  // this has to happen here, in case historical map gets added
  L.control.layers(null, overlay_control).addTo(map);
  markers.addTo(map);

  populateMapFromTable(map, map_cfg.on_row_click_zoom, markers, table_cfg);
}
