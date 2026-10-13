/*this cfg describes some of the features of the leaflet map and it't functions*/
/*its used by make_map_and_table.js to build a DataTable (see table_cfg below)
and a leaflet map from data of an html table*/

/*this defines some features of the leaflet map
his simply is passed over to leaflet, consult docs
for more info */
const map_cfg = {
  div_id: "map",
  initial_zoom: "5",
  max_zoom: "15",
  min_zoom: "2",
  /* zoom level for a place on the map focused by clicking the corresponding row */
  on_row_click_zoom: 10,
  initial_coordinates: [47.0708, 15.4386],
  base_map_url:
      "https://tile.openstreetmap.org/{z}/{x}/{y}{r}.png",
  /* some map providers need subdomains */
  subdomains: "abcd",
  attribution:
  '<a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
  base_map_label: "Aktuelle Karte"
};

/*id of the html table (see listplace.xsl) that make_map_and_table.js turns
into a DataTable; its row data is read through DataTables' own row().data(),
keyed by the lowercased <th> labels (ortsname, lat, lng, linktoentity, ...)*/
const table_cfg = {
  table_div_html_id: "placesTable",
};

/*optional you can define some wms config. If provided and passed to 
build_map_and_table a wms layer is added to your map,
including a layer controll;
if you don't need this, ignore it*/
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

let tms_cfg = {
  label: "Europa um 1700",
  tms_url: "https://emt-project.github.io/mapserver/map_01/{z}/{x}/{y}.png",
  layerOptions: {tms: 1, opacity: 0.8, minZoom: 2, maxZoom: 12, attribution: "Austrian National Library (ÖNB)"},
}

//////////////////////////////////////////////////
/* some functions to influence the visualization*/
//////////////////////////////////////////////////

/*the Ortsname cell contains a link to the place's detail page, so strip the
markup before using its text as a map label*/
function stripHtml(html) {
  const container = document.createElement('div');
  container.innerHTML = html;
  return container.textContent.trim();
}

/*define the way you want to created an popup lable on the map
row_data comes from DataTables' row().data(), keyed by the lowercased
column headers (ortsname, linktoentity, ...)*/
function popupLabelCreator(row_data) {
  return `<a href="${row_data.linktoentity}.html">${stripHtml(row_data.ortsname)}</a>`;
}

function tooltipLabelcreator(row_data) {
  return stripHtml(row_data.ortsname);
}

const get_popup_label_string_html = popupLabelCreator
const get_tooltip_label = tooltipLabelcreator
