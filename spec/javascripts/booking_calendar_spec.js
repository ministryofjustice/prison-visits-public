var i18n = {
  "days": ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"],
  "months": ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"],
  "abbrMonths": ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
  "am": "am",
  "pm": "pm",
  "hour": {
    "one": "hr",
    "other": "hrs"
  },
  "minute": {
    "one": "min",
    "other": "mins"
  }
};

var slotSource = $('<select class="SlotPicker-input" name="slots_step[option_0]" id="slots_step_option_0">' +
  '<option value=""></option> ' +
  '<option value="2017-02-09T14:00/16:00">Thursday 9 February 2: 00 pm</option> ' +
  '<option value="2017-02-10T14:00/16:00">Friday 10 February 2: 00 pm</option> ' +
  '<option value="2017-02-11T09:15/11:15">Saturday 11 February 9: 15 am</option> ' +
  '<option value="2017-02-11T14:00/16:00">Saturday 11 February 2: 00 pm</option> ' +
  '<option value="2017-02-12T14:00/16:00">Sunday 12 February 2: 00 pm</option> ' +
  '<option value="2017-02-13T09:15/11:15">Monday 13 February 9: 15 am</option> ' +
  '<option value="2017-02-13T14:00/16:00">Monday 13 February 2: 00 pm</option> ' +
  '<option value="2017-02-14T14:00/16:00">Tuesday 14 February 2: 00 pm</option> ' +
  '<option value="2017-02-15T09:15/11:15">Wednesday 15 February 9: 15 am</option> ' +
  '<option value="2017-02-15T14:00/16:00">Wednesday 15 February 2: 00 pm</option> ' +
  '<option value="2017-02-16T14:00/16:00">Thursday 16 February 2: 00 pm</option> ' +
  '<option value="2017-02-17T14:00/16:00">Friday 17 February 2: 00 pm</option> ' +
  '<option value="2017-02-18T09:15/11:15">Saturday 18 February 9: 15 am</option> ' +
  '<option value="2017-02-18T14:00/16:00">Saturday 18 February 2: 00 pm</option> ' +
  '<option value="2017-02-19T14:00/16:00">Sunday 19 February 2: 00 pm</option> ' +
  '<option value="2017-02-20T09:15/11:15">Monday 20 February 9: 15 am</option> ' +
  '<option value="2017-02-20T14:00/16:00">Monday 20 February 2: 00 pm</option> ' +
  '<option value="2017-02-21T14:00/16:00">Tuesday 21 February 2: 00 pm</option> ' +
  '<option value="2017-02-22T09:15/11:15">Wednesday 22 February 9: 15 am</option> ' +
  '<option value="2017-02-22T14:00/16:00">Wednesday 22 February 2: 00 pm</option> ' +
  '<option value="2017-02-23T14:00/16:00">Thursday 23 February 2: 00 pm</option> ' +
  '<option value="2017-02-24T14:00/16:00">Friday 24 February 2: 00 pm</option> ' +
  '<option value="2017-02-25T09:15/11:15">Saturday 25 February 9: 15 am</option> ' +
  '<option value="2017-02-25T14:00/16:00">Saturday 25 February 2: 00 pm</option> ' +
  '<option value="2017-02-26T14:00/16:00">Sunday 26 February 2: 00 pm</option> ' +
  '<option value="2017-02-27T09:15/11:15">Monday 27 February 9: 15 am</option> ' +
  '<option value="2017-02-27T14:00/16:00">Monday 27 February 2: 00 pm</option> ' +
  '<option value="2017-02-28T14:00/16:00">Tuesday 28 February 2: 00 pm</option> ' +
  '<option value="2017-03-01T09:15/11:15">Wednesday 1 March 9: 15 am</option> ' +
  '<option value="2017-03-01T14:00/16:00">Wednesday 1 March 2: 00 pm</option> ' +
  '<option value="2017-03-02T14:00/16:00">Thursday 2 March 2: 00 pm</option> ' +
  '<option value="2017-03-03T14:00/16:00">Friday 3 March 2: 00 pm</option></select > '
);

var slotList = $('<div id="js-slotAvailability" aria-describedby="slots" aria-live="assertive" aria-atomic="true" aria-relevant="additions removals"></div>');

var slotTarget = $('<div id="js-slotTarget" aria-hidden="true">' +
  '<h3 class="text-secondary push-bottom--half">Your selection</h3>' +
  '<div class="date-box slot-selected" aria-live="assertive" aria-atomic="true" aria-relevant="text">' +
  '<span class="date-box__number">1</span>' +
  '<span class="date-box__day"></span>' +
  '<br/>' +
  '<span class="date-box__slot"></span>' +
  '</div>' +
  '</div>');

var html = $('<div id="slot_0" class="js-bookingCalendar calendar" data-target-id="dateValue" data-slot-source="slots_step_option_0" data-slot-list="js-slotAvailability" data-slot-target="js-slotTarget">' +
  '<div id="month-wrap">' +
  '    <div id="bn_prev" role="button" aria-labelledby="bn_prev-label" tabindex="0"></div>' +
  '    <div id="month" class="bold-medium" role="heading" aria-live="assertive" aria-atomic="true"></div>' +
  '    <div id="bn_next" role="button" aria-labelledby="bn_next-label" tabindex="0"></div>' +
  '</div>' +
  '<table id="js-calendarTable" class="booking-calendar" role="grid" aria-activedescendant="errMsg" aria-labelledby="month" tabindex="0">' +
  '    <thead>' +
  '<tr id="weekdays">' +
  '<th id="Sun">' +
  '<abbr title="Sun">Sun</abbr>' +
  '</th>' +
  '<th id="Mon">' +
  '<abbr title="Mon">Mon</abbr>' +
  '</th>' +
  '<th id="Tue">' +
  '<abbr title="Tue">Tue</abbr>' +
  '</th>' +
  '<th id="Wed">' +
  '<abbr title="Wed">Wed</abbr>' +
  '</th>' +
  '<th id="Thu">' +
  '<abbr title="Thu">Thu</abbr>' +
  '</th>' +
  '<th id="Fri">' +
  '<abbr title="Fri">Fri</abbr>' +
  '</th>' +
  '<th id="Sat">' +
  '<abbr title="Sat">Sat</abbr>' +
  '</th>' +
  '</tr>' +
  '    </thead>' +
  '    <tbody>' +
  '<tr><td id="errMsg" colspan="7">Javascript must be enabled</td></tr>' +
  '    </tbody>' +
  '</table>' +
  '' +
  '<div id="bn_prev-label" class="visuallyhidden">Go to previous month</div>' +
  '<div id="bn_next-label" class="visuallyhidden">Go to next month</div>' +
  '</div>');

var slots = [{
  'availability': 1,
  'chosen': false,
  'date': '2017-02-10'
}];

describe('Modules.bookingCalendar', function() {

  beforeEach(function() {
    $('body').append(slotSource).append(html).append(slotList).append(slotTarget);
  });

  describe('...Methods', function() {
    describe('...init', function() {

      beforeEach(function() {
        spyOn(moj.Modules.bookingCalendar, 'cacheEls');
        spyOn(moj.Modules.bookingCalendar, 'bindEvents');

      });

      it('should call `this.cacheEls`', function() {
        moj.Modules.bookingCalendar.init();
        expect(moj.Modules.bookingCalendar.cacheEls).toHaveBeenCalled();
      });

      it('should call `this.bindEvents`', function() {
        moj.Modules.bookingCalendar.init();
        expect(moj.Modules.bookingCalendar.bindEvents).toHaveBeenCalled();
      });
    });

    describe('...after init', function() {
      beforeEach(function() {
        moj.Modules.bookingCalendar.init();
      });

      it('should cache the `#slots_step_option_0` element as the slot source', function() {
        expect(moj.Modules.bookingCalendar.$slotSource[0].outerHTML).toBe(slotSource[0].outerHTML);
      });

      it('should be only one $slotSource', function() {
        expect(moj.Modules.bookingCalendar.$slotSource.length).toBe(1);
      });

      it('should cache the $slotList', function() {
        expect(moj.Modules.bookingCalendar.$slotList[0].outerHTML).toBe(slotList[0].outerHTML);
      });

      it('should cache the $slotTarget', function() {
        expect(moj.Modules.bookingCalendar.$slotTarget[0].outerHTML).toBe(slotTarget[0].outerHTML);
      });
    });

    describe('get list of available slots', function() {
      beforeEach(function() {
        moj.Modules.bookingCalendar.init();
        moj.Modules.bookingCalendar.settings.i18n = i18n;
        moj.Modules.bookingCalendar.initialize();
      });
      it('should return the select options as an array', function() {
        var arr = moj.Modules.bookingCalendar.getAvailableSlots();
        expect(Array.isArray(arr)).toBe(true);
      });
      it('should be defined', function() {
        expect(moj.Modules.bookingCalendar.availableSlots).toBeDefined();
      });
      it('should return 23 available dates', function() {
        var arr = moj.Modules.bookingCalendar.availableSlots;
        expect(arr.length).toBe(23);
      });
      it('should have a first available date as 9th Feb 2017', function() {
        var arr = moj.Modules.bookingCalendar.availableSlots;
        expect(arr[0].date).toEqual('2017-02-09');
      });
    });

    describe('populate the calendar grid', function() {
      beforeEach(function() {
        moj.Modules.bookingCalendar.init();
        moj.Modules.bookingCalendar.settings.i18n = i18n;
        moj.Modules.bookingCalendar.initialize();
      });
      it('should create at least 2 rows of dates', function() {
        var rows = $('#js-calendarTable tbody tr');
        expect(rows.length).toBeGreaterThan(2);
      });
      it('should create a table cell with id `day9`', function() {
        expect($('#js-calendarTable #day9').length).toBe(1);
      });
    });

    describe('choosing a slot', function() {
      beforeEach(function() {
        moj.Modules.bookingCalendar.init();
        moj.Modules.bookingCalendar.settings.i18n = i18n;
        moj.Modules.bookingCalendar.initialize();
        $('#day11').trigger('click');
      });
      describe('choose a date', function() {
        it('should set a selected class', function() {
          expect($('#js-calendarTable #day11.selected').length).toBe(1);
        });
        it('should create two radio input slots for 11th February', function() {
          expect(slotList.find('input').length).toBe(2);
        });
      });
      describe('choose a slot', function() {
        it('should update the chosen slot date box', function() {
          $('#slot-step-2017-02-11-0').trigger('click');
          var box = $('.date-box.slot-selected');
          expect(box.find('.date-box__day')[0].outerText).toBe('Saturday 11 February');
        });
      });
    });
  });
});