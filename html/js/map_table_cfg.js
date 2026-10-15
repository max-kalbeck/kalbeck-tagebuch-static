/* Configuration for the Leaflet map and DataTable.
 * Used by make_map_and_table.js to build a map and table from an HTML table.
 */

/* Leaflet map configuration */
const map_cfg = {
  div_id: "map",
  initial_zoom: 5,
  max_zoom: 9,
  min_zoom: 2,

  /* Zoom level when clicking a table row */
  on_row_click_zoom: 9,

  initial_coordinates: [47.0708, 15.4386],
  base_map_url: "https://tile.openstreetmap.org/{z}/{x}/{y}{r}.png",
  attribution:
    '<a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
  base_map_label: "Aktuelle Karte",
};

/* HTML table configuration.
 * DataTables reads row data using lowercased column headers,
 * e.g. ortsname, lat, lng and linktoentity.
 */
const table_cfg = {
  table_div_html_id: "placesTable",
};

/* Optional WMS overlay configuration */
let wms_cfg = {
  label: "Stadtplan 1858 (k.k. Ministerium des Inneren)",
  wms_url: "https://data.wien.gv.at/daten/wms?version=1.1.1",
  layerOptions: {
    service: "WMS",
    version: "1.1.1",
    request: "GetMap",
    contextualWMSLegend: "0",
    crs: L.CRS.EPSG4326,
    dpiMode: "7",
    featureCount: "10",
    format: "image/png",
    layers: "HISTWIENPL1858OGD",
    url: "https://data.wien.gv.at/daten/wms?version%3D1.1.1",
    opacity: 0.5,
  },
};

/* Optional TMS overlay configuration */
let tms_cfg = {
  label: "Europa um 1700",
  tms_url: "https://emt-project.github.io/mapserver/map_01/{z}/{x}/{y}.png",
  layerOptions: {
    tms: 1,
    opacity: 0.8,
    minZoom: 2,
    maxZoom: 9,
    attribution: "Austrian National Library (ÖNB)",
  },
};

/* Extract plain text from the Ortsname cell, which contains a link. */
function stripHtml(html) {
  const container = document.createElement("div");
  container.innerHTML = html;
  return container.textContent.trim();
}

/* Create the map popup label.
 * row_data comes from DataTables and is keyed by lowercased column headers.
 */
function popupLabelCreator(row_data) {
  return `<a href="${row_data.linktoentity}.html">${stripHtml(row_data.ortsname)}</a>`;
}

/* Create the map tooltip label. */
function tooltipLabelcreator(row_data) {
  return stripHtml(row_data.ortsname);
}

const get_popup_label_string_html = popupLabelCreator;
const get_tooltip_label = tooltipLabelcreator;
