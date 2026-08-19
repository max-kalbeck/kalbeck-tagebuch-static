let calendar;
let calendarData = [];

fetch('calendarData.json')
  .then(response => {
    if (!response.ok) {
      throw new Error(`HTTP error: ${response.status}`);
    }
    return response.json();
  })
  .then(json => {
    calendarData = json;
    initCalendar();
  })
  .catch(error => {
    console.error('Could not load calendar data:', error);
  });


function getYear(item) {
  return item.startDate.split('-')[0];
}


function createyearcell(val) {
  return (val !== undefined) ? `
    <div class="col-xs-6" style="width: auto;">
      <button
        id="ybtn${val}"
        class="btn btn-light rounded-0 yearbtn"
        value="${val}"
        onclick="updateyear(this.value)">
        ${val}
      </button>
    </div>` : '';
}


function initCalendar() {
  const years = Array.from(
    new Set(calendarData.map(getYear))
  ).sort();

  const startYear = parseInt(years[0]);

  const data = calendarData.map(r => ({
    startDate: new Date(r.startDate),
    endDate: new Date(r.startDate),
    name: r.name,
    linkId: r.id,
    color: '#0d6efd'
  })).filter(
    r => r.startDate.getFullYear() === startYear
  );

  const yearsTable = document.getElementById('years-table');

  for (let i = 0; i < years.length; i++) {
    yearsTable.insertAdjacentHTML(
      'beforeend',
      createyearcell(years[i])
    );
  }

  calendar = new Calendar('#calendar', {
    startYear: startYear,
    language: 'de',
    dataSource: data,
    displayHeader: false,

    clickDay: function(e) {
      const ev = e && e.events && e.events[0];

      if (ev && ev.linkId) {
        window.location = ev.linkId;
      }
    },

    renderEnd: function(e) {
      const buttons = document.querySelectorAll('.yearbtn');

      for (let i = 0; i < buttons.length; i++) {
        buttons[i].classList.remove('focus');
      }

      document
        .getElementById(`ybtn${e.currentYear}`)
        .classList.add('focus');
    }
  });
}


function updateyear(year) {
  calendar.setYear(year);

  const dataSource = calendarData.map(r => ({
    startDate: new Date(r.startDate),
    endDate: new Date(r.startDate),
    name: r.name,
    linkId: r.id,
    color: '#0d6efd'
  })).filter(
    r => r.startDate.getFullYear() === parseInt(year)
  );

  calendar.setDataSource(dataSource);
}