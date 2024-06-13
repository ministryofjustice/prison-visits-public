describe('moj.Modules.Slotpicker', function() {

  var datePicker,
      duplicateArray = ['1', '1', '2', '3', '3', '4'];

  beforeEach(function() {
    loadFixtures('calendar.html');
    var calendar = $('.js-calendar');
    datePicker = new moj.Modules.Slotpicker.Datepicker(calendar, calendar.data());
    moj.Modules.Slotpicker.Helpers.init();
    moj.Modules.Slotpicker.SlotSource.init();
    moj.Modules.Analytics.send = function() {};
  });

  describe('fixture', function() {
    it('should contain datePicker', function() {
      expect(datePicker).toExist();
    });
  });

  describe('moj', function() {
    it('should be an object', function() {
      expect(typeof moj).toEqual('object');
    });
  });

  describe('moj.Modules', function() {
    it('should be an object', function() {
      expect(typeof moj.Modules).toEqual('object');
    });
  });

  describe('on init', function(){
    beforeEach(function() {
      spyOn(moj.Modules.Slotpicker, 'setup');
    });
    it('should call `this.setup`', function(){
      moj.Modules.Slotpicker.init();
      moj.Events.trigger('render');
      expect(moj.Modules.Slotpicker.setup).toHaveBeenCalled();
    });
  });

  describe('moj.Modules.Slotpicker.Datepicker', function() {
    beforeEach(function() {
      spyOn(datePicker, 'setup');
    });
    it('should be a object', function() {
      expect(typeof datePicker).toEqual('object');
    });
    it('should call `this.setup`', function() {
      datePicker.init();
      expect(datePicker.setup).toHaveBeenCalled();
    });
  });

  describe('moj.Modules.Slotpicker.Calendar', function() {
    beforeEach(function() {
      datePicker.init();
    });
    it('should be a function', function(){
      expect(typeof moj.Modules.Slotpicker.Calendar).toEqual('function');
    });
    describe('setting up the calendars', function(){
      it('should create at least 2 rows of dates', function() {
        var rows = $('#js-calendarTable tbody tr');
        expect(rows.length).toBeGreaterThan(2);
      });
      it('should create a table cell with id `day9`', function() {
        expect($('#js-calendarTable #day9')).toExist();
      });
      it('should hide the selected date box', function() {
        expect($('#js-slotTarget').attr('aria-hidden')).toBe('true');
      });
      describe('clicking day 25', function(){
        var $day25;
        var $day26;
        beforeEach(function() {
          $day25 = $('#js-calendarTable #day25').click();
          $day26 = $('#js-calendarTable #day26');
        });
        it('should set focus class on cell', function(){
          expect($day25).toHaveClass('focus');
          expect($day25.find('.cell-date')).toHaveAttr('aria-selected', 'true');
        });
        describe('clicking day 26', function(){
          it('should unset focus class on day 25', function(){
            $day26.click();
            expect($day25).not.toHaveClass('focus');
            expect($day25.find('.cell-date')).toHaveAttr('aria-selected', 'false');
          });
        });
      });
    });
  });

  describe('moj.Modules.Slotpicker.Slots', function(){
    var $slotList;
    beforeEach(function() {
      datePicker.init();
      $slotList = $('#js-slotAvailability');
    });
    it('should be a function', function(){
      expect(typeof moj.Modules.Slotpicker.Slots).toEqual('function');
    });
    describe('slot list', function(){
      it('should be empty on init', function(){
        expect($slotList.html().length).toBe(0);
      });
    });
    describe('clicking day 25', function(){
      var $day25;
      beforeEach(function() {
        $day25 = $('#js-calendarTable #day25').click();
      });
      it('should add html to the slot list', function(){
        expect($slotList.html().length).not.toBe(0);
      });
      describe('checking the first slot radio button', function(){
        beforeEach(function() {
          $slotList.find('input[type="radio"]').eq(0).click();
        });
        it('should show the selected date box', function(){
          expect($('#js-slotTarget').attr('aria-hidden')).toBe('false');
        });
      });
    });
  });

  describe('moj.Modules.Slotpicker.SlotSource', function() {
    var slotSource,
        slotValue = '2017-02-09T14:00/16:00';
    beforeEach(function() {
      slotSource = $('#slots_step_option_0');
    });
    it('should be an object', function(){
      expect(typeof moj.Modules.Slotpicker.SlotSource).toEqual('object');
    });
    describe('Methods', function(){
      it('getValue should get the value', function(){
        expect(moj.Modules.Slotpicker.SlotSource.getValue()).toBe('');
      });
      it('setValue should set the value', function(){
        moj.Modules.Slotpicker.SlotSource.setValue(slotValue);
        expect(slotValue).toBe(slotSource.val());
      });
      it('removeSlot should set the value to null', function(){
        moj.Modules.Slotpicker.SlotSource.setValue(slotValue);
        moj.Modules.Slotpicker.SlotSource.removeSlot();
        expect(moj.Modules.Slotpicker.SlotSource.getValue()).toBe('');
      });
      it('uniqueArray should be a boolean', function(){
        var uniqueArray = moj.Modules.Slotpicker.SlotSource.uniqueArray(duplicateArray);
        expect(typeof uniqueArray).toEqual('boolean');
        expect(uniqueArray).toEqual(true);
        expect(moj.Modules.Slotpicker.SlotSource.uniqueArray(['1'])).toEqual(false);
      });
      it('getSlotInformation should be an object', function(){
        var availableSlots = moj.Modules.Slotpicker.SlotSource.getSlotInformation();
        expect(typeof availableSlots).toEqual('object');
        expect(availableSlots.length).toEqual(32);
      });

      it('getAvailableSlots should be an object', function(){
        var availableSlots = moj.Modules.Slotpicker.SlotSource.getAvailableSlots();
        expect(typeof availableSlots).toEqual('object');
        expect(availableSlots.length).toEqual(23);
      });
    });
  });

  describe('moj.Modules.Slotpicker.Helpers', function() {
    it('should be an object', function(){
      expect(typeof moj.Modules.Slotpicker.Helpers).toEqual('object')
    });
    describe('Methods', function(){
      it('calcDaysInMonth should be a number', function(){
        expect(typeof moj.Modules.Slotpicker.Helpers.calcDaysInMonth(2018, 0)).toEqual('number');
        expect(moj.Modules.Slotpicker.Helpers.calcDaysInMonth(2018, 0)).toEqual(31);
      });
      it('calcStartWeekday should be a number', function(){
        expect(typeof moj.Modules.Slotpicker.Helpers.calcStartWeekday(2018, 0)).toEqual('number');
        expect(moj.Modules.Slotpicker.Helpers.calcStartWeekday(2018, 0)).toEqual(1);
      });
      it('makeDateObj should be a date object', function(){
        var date = new Date(2018, 0, 31);
        expect(typeof moj.Modules.Slotpicker.Helpers.makeDateObj('2018-01-31')).toEqual('object');
        expect(moj.Modules.Slotpicker.Helpers.makeDateObj('2018-01-31')).toEqual(date);
      });
      it('splitDateAndSlot should be an object', function(){
        var slot = '2018-01-31T14:15/15:50',
            splitSlot = ['2018-01-31', '14:15/15:50'];
        expect(typeof moj.Modules.Slotpicker.Helpers.splitDateAndSlot(slot)).toEqual('object');
        expect(moj.Modules.Slotpicker.Helpers.splitDateAndSlot(slot)).toEqual(splitSlot);
      });
      it('splitTime should be an object', function(){
        var times = ['14:15', '15:50'];
        expect(typeof moj.Modules.Slotpicker.Helpers.splitTime('14:15/15:50')).toEqual('object');
        expect(moj.Modules.Slotpicker.Helpers.splitTime('14:15/15:50')).toEqual(times);
      });
      it('getUnique should be an object', function(){
        expect(typeof moj.Modules.Slotpicker.Helpers.getUnique(duplicateArray)).toEqual('object');
        expect(moj.Modules.Slotpicker.Helpers.getUnique(duplicateArray)).toEqual(['1', '2', '3', '4']);
      });
      it('timeFromSlot should be an object', function(){
        var date = new Date(),
            time = '14:15';
        date.setHours(14);
        date.setMinutes(15);
        expect(typeof moj.Modules.Slotpicker.Helpers.timeFromSlot(time)).toEqual('object');
        expect(moj.Modules.Slotpicker.Helpers.timeFromSlot(time).toTimeString()).toEqual(date.toTimeString());
      });
      it('formatTime should be an string', function(){
        expect(typeof moj.Modules.Slotpicker.Helpers.formatTime('14:15')).toEqual('string');
        expect(moj.Modules.Slotpicker.Helpers.formatTime('14:15')).toEqual('2:15pm');
      });
      it('formatTimeDuration should be an string', function(){
        expect(typeof moj.Modules.Slotpicker.Helpers.formatTimeDuration('14:15/15:50')).toEqual('string');
        expect(moj.Modules.Slotpicker.Helpers.formatTimeDuration('14:15/15:50')).toEqual('1 hour 35 mins');
      });
      it('formatSlot should be an object', function(){
        var slot = {
          day: 'Wednesday',
          date: {day: 31, monthIndex: 0, year: 2018},
          formattedDate: '31 January',
          time: '2:15pm',
          duration: '1 hour 35 mins'
        }
        expect(typeof moj.Modules.Slotpicker.Helpers.formatSlot('2018-01-31T14:15/15:50')).toEqual('object');
        expect(moj.Modules.Slotpicker.Helpers.formatSlot('2018-01-31T14:15/15:50')).toEqual(slot);
      });
      it('duration should be an string', function(){
        var start = new Date(2018, 0, 31, 14, 0, 0, 0),
            end = new Date(2018, 0, 31, 15, 35, 0, 0);
        expect(typeof moj.Modules.Slotpicker.Helpers.duration(start, end)).toEqual('string');
        expect(moj.Modules.Slotpicker.Helpers.duration(start, end)).toEqual('1 hour 35 mins');
      });
    });
  });


});