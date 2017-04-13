var slots = [{
  'availability': 1,
  'chosen': false,
  'date': '2017-02-10'
}];

describe('Modules.bookingCalendar', function() {

  beforeEach(function() {
    loadFixtures('calendar.html');
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
        moj.Modules.bookingCalendar.initialize();
      });


      it('should cache the `#slots_step_option_0` element as the slot source', function() {
        var slotSource = $('.SlotPicker-input');
        expect(moj.Modules.bookingCalendar.$slotSource[0].outerHTML).toBe(slotSource[0].outerHTML);
      });

      it('should be only one $slotSource', function() {
        expect(moj.Modules.bookingCalendar.$slotSource.length).toBe(1);
      });

      it('should cache the $slotList', function() {
        var slotList = $('#js-slotAvailability');
        expect(moj.Modules.bookingCalendar.$slotList[0].outerHTML).toBe(slotList[0].outerHTML);
      });

      it('should cache the $slotTarget', function() {
        var slotTarget = $('#js-slotTarget');
        expect(moj.Modules.bookingCalendar.$slotTarget[0].outerHTML).toBe(slotTarget[0].outerHTML);
      });
    });

    describe('get list of available slots', function() {
      beforeEach(function() {
        moj.Modules.bookingCalendar.init();
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
        moj.Modules.bookingCalendar.initialize();
      });
      it('should create at least 2 rows of dates', function() {
        var rows = $('#js-calendarTable tbody tr');
        expect(rows.length).toBeGreaterThan(2);
      });
      it('should create a table cell with id `day9`', function() {
        expect($('#js-calendarTable #day9').length).toBe(1);
      });
      it('should hide the selected date box', function() {
        expect($('#js-slotTarget').attr('aria-hidden')).toBe('true');
      });
    });

    describe('choosing a slot', function() {
      beforeEach(function() {
        moj.Modules.bookingCalendar.init();
        moj.Modules.bookingCalendar.initialize();
        $('#day11').trigger('click');
      });
      describe('choose a date', function() {
        it('should set a selected class', function() {
          expect($('#js-calendarTable #day11.selected').length).toBe(1);
        });
        it('should create two radio input slots for 11th February', function() {
          var slotList = $('#js-slotAvailability');
          expect(slotList.find('input').length).toBe(2);
        });
      });
      describe('choose a slot', function() {
        beforeEach(function() {
          $('#slot-step-2017-02-11-0').trigger('click');
        });

        it('should update the chosen slot date box', function() {
          var box = $('.date-box.slot-selected');
          expect(box.find('.date-box__day')[0].outerText).toBe('Saturday 11 February');
        });
        it('should show the selected date box', function() {
          expect($('#js-slotTarget').attr('aria-hidden')).toBe('false');
        });
      });
    });
  });
});