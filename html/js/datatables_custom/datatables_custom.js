// Unique cell values of a column with their row counts, as searchList options
function countOptions(tableId, index) {
    const counts = new Map();

    document.querySelectorAll(`#${tableId} tbody tr td:nth-child(${index + 1})`).forEach((td) => {
        const value = td.textContent.trim();

        if (value) {
            counts.set(value, (counts.get(value) || 0) + 1);
        }
    });

    return [...counts]
        .sort(([a, countA], [b, countB]) => countB - countA || a.localeCompare(b, 'de'))
        .map(([value, count]) => ({ label: `${value} (${count})`, value }));
}

function updateInfo(table) {
    const info = table.page.info();

    document.querySelector('#custom-info-box').textContent =
        `${info.recordsDisplay} von ${info.recordsTotal} Einträgen`;
}

// ColumnControl has no tooltip option for buttons
function addSearchListTooltips(tableId) {
    document.querySelectorAll(`#${tableId} thead .dtcc-button_searchlist`).forEach((button) => {
        button.title = 'Liste aller Werte öffnen und nach Werten filtern';
    });
}

// ColumnControl renders the search-logic <select> without an accessible name
function labelSearchLogicSelects(tableId) {
    document.querySelectorAll(`#${tableId} thead th`).forEach((th, index) => {
        const label = th.querySelector('.dt-column-title').textContent.trim();
        const select = document.querySelectorAll(`#${tableId} thead span.dtcc select.form-select`)[index];

        if (label && select) {
            select.setAttribute('aria-label', `Suchmodus für ${label}`);
        }
    });
}

// Builds a DataTable out of a plain HTML table whose <th> elements carry
// data-dt-* hints: data-dt-searchlist="true" adds a value-picker dropdown,
// data-dt-visible="false" hides a column (e.g. data only needed by other
// scripts, such as the coordinates behind the places map) by default.
//
// opts.onInit(api) / opts.onDraw(api) / opts.onRowClick(event, tr, api) let
// callers (e.g. make_map_and_table.js) hook extra behaviour onto the table
// without duplicating the setup below.
function initDataTable(tableId, opts = {}) {
    const columns = [];
    const noVisTargets = [0];

    document.querySelectorAll(`#${tableId} thead th`).forEach((th, index) => {
        const label = th.textContent.trim();
        const isVisible = th.dataset.dtVisible !== 'false';

        // columns hidden by default carry no end-user meaning on their own
        // (e.g. raw coordinates), so keep them out of the "Spalten" toggle too
        if (!isVisible && index !== 0) {
            noVisTargets.push(index);
        }

        const sortContent = ['orderStatus'];

        if (th.dataset.dtSearchlist === 'true') {
            sortContent.push({
                extend: 'dropdown',
                icon: 'search',
                iconActive: 'searchActive',
                className: 'searchlist',
                text: `Werte auswählen: ${label}`,
                content: [{ extend: 'searchList', options: countOptions(tableId, index) }]
            });
        }

        columns.push({
            data: label.toLowerCase(),
            visible: isVisible,
            columnControl: [
                {
                    target: 0,
                    content: sortContent
                },
                {
                    target: 1,
                    content: [
                        {
                            extend: 'search',
                            placeholder: label
                        }
                    ]
                }
            ]
        });
    });

    const table = new DataTable(`#${tableId}`, {
        columnDefs: [
            {
                targets: noVisTargets,
                className: 'noVis'
            }
        ],
        layout: {
            topStart: {
                buttons: [{
                        extend: 'colvis',
                        columns: ':not(.noVis)',
                    }]
            },
            topEnd: {
                buttons: [
                    {
                        extend: 'collection',
                        text: 'Export',
                        buttons: ['copy', 'csv', 'print']
                    }
                ]
            },
            bottomStart: 'pageLength',
            bottomEnd: 'paging'
        },
        language: {
            url: 'js/datatables_custom/de-DE.json',
        },
        initComplete: function () {
            const api = this.api();
            updateInfo(api);

            if (typeof opts.onInit === 'function') {
                opts.onInit(api);
            }
            // ColumnControl builds its search-row DOM asynchronously after initComplete fires
            setTimeout(() => {
                labelSearchLogicSelects(tableId);
                addSearchListTooltips(tableId);
            }, 0);
        },

        columns: columns,

        ordering: {
            indicators: false
        }
    });

    table.on('draw', function () {
        updateInfo(table);

        if (typeof opts.onDraw === 'function') {
            opts.onDraw(table);
        }
    });

    table.on('click', 'tbody tr', function (event) {
        if (typeof opts.onRowClick === 'function') {
            opts.onRowClick(event, this, table);
            return;
        }

        if (event.target.closest('a')) {
            return;
        }

        const link = this.querySelector('a');

        if (link) {
            link.click();
        }
    });

    return table;
}

// Auto-initialise the citation/work-list table used e.g. on listbibl.html.
// Pages with other tables (e.g. listplace.html) call initDataTable() themselves.
if (document.getElementById('myTable')) {
    initDataTable('myTable');
}
