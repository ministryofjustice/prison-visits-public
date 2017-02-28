(function() {
  'use strict';

  moj.Modules.bookingCalendar = {
    el: '.js-bookingCalendar',

    settings: {
      i18n: moj.i18n
    },

    init: function() {
      if ($(this.el) && $(this.el).length > 0) {
        this.cacheEls();
        this.bindEvents();
        moj.Events.on('render', $.proxy(this.initialize, this));
      }
    },

    /**
     * Cache the DOM elements
     * @param  {object} $el
     */
    cacheEls: function() {
      this.$el = $(this.el); //$('.js-bookingCalendar');
      this.$monthObj = this.$el.find('#month');
      this.$prev = this.$el.find('#bn_prev');
      this.$next = this.$el.find('#bn_next');
      this.$grid = this.$el.find('#js-calendarTable');
      this.$slotSource = $('#' + this.$el.data('slotSource'));
      this.$slotList = $('#' + this.$el.data('slotList'));
      this.$slotTarget = $('#' + this.$el.data('slotTarget'));
      this.slotNumber = this.$el.data('slotNumber');
    },

    /**
     * Bind events
     */
    bindEvents: function() {
      var self = this;

      // bind button handlers
      this.$prev.click(function(e) {
        return self.handlePrevClick(e);
      });

      this.$next.click(function(e) {
        return self.handleNextClick(e);
      });

      this.$prev.keydown(function(e) {
        return self.handlePrevKeyDown(e);
      });

      this.$next.keydown(function(e) {
        return self.handleNextKeyDown(e);
      });

      // bind grid handlers
      this.$grid.keydown(function(e) {
        return self.handleGridKeyDown(e);
      });

      this.$grid.keypress(function(e) {
        return self.handleGridKeyPress(e);
      });

      this.$grid.focus(function(e) {
        return self.handleGridFocus(e);
      });

      this.$grid.blur(function(e) {
        return self.handleGridBlur(e);
      });

      this.$grid.delegate('td:not(.empty, .disabled)', 'click', function(e) {
        return self.handleGridClick(this, e);
      });

      // bind radio button handler
      this.$slotList.on('change', 'input[type=radio][name=slot_step_0]', function(e) { // THIS MAY NEED TO CHANGE THE NAME FOR THE SLOT STEP!!!
        var slot = $(e.currentTarget).val();

        self.updateSource(slot);
        self.updateSelectedSlot(slot);
        self.handleSlotChosen();
      });

      this.$slotTarget.on('click', '.date-box__action', function(e) {
        e.preventDefault();
        e.stopPropagation();
        self.removeSlot();
      });
    },

    /**
     * Set the default values and current month and show the grid
     */
    initialize: function() {
      this.availableSlots = this.getAvailableSlots();
      this.dateObj = new Date();
      this.curYear = this.dateObj.getFullYear();
      this.year = this.curYear;
      var firstDate = this.availableSlots[0].date.split('-');
      this.curMonth = new Date(firstDate[0], parseInt(firstDate[1]) - 1, firstDate[2]).getMonth();
      this.month = this.curMonth;
      this.currentDate = false;
      this.date = this.dateObj.getDate();
      this.keys = {
        tab: 9,
        enter: 13,
        esc: 27,
        space: 32,
        pageup: 33,
        pagedown: 34,
        end: 35,
        home: 36,
        left: 37,
        up: 38,
        right: 39,
        down: 40
      };

      // display the current month
      this.$monthObj.html(this.settings.i18n.months[this.month] + ' ' + this.year);

      // populate the calendar grid
      this.popGrid();

      // update the table's activedescdendant to point to the current day
      this.$grid.attr('aria-activedescendant', this.$grid.find('.today').attr('id'));

      if (this.selectedSlot && this.selectedDate) {
        this.updateSlots(this.selectedDate);
        this.handleSlotChosen();
      }
    },

    /**
     * @return {array} of <option> from the $slotSource
     */
    getSlotInformation: function() {
      return this.$slotSource.first().find('option').map(function() {
        var v = $(this).val();
        if (v !== '') {
          return $(this);
        }
      }).get();
    },

    /**
     * @param  {array} inputArray
     * @return {array} of unique values
     */
    getUnique: function(inputArray) {
      var outputArray = [];
      for (var i = 0; i < inputArray.length; i++) {
        if ((jQuery.inArray(inputArray[i], outputArray)) == -1) {
          outputArray.push(inputArray[i]);
        }
      }
      return outputArray;
    },

    /**
     * @return {array} List of day objects with the time slots available and messages
     */
    getAvailableSlots: function() {
      var slots, i, times = [],
        day, days = [],
        previous, statuses = [],
        chosenArr = [],
        n, p;

      slots = this.getSlotInformation();

      for (i = 0; i < slots.length; i++) {
        var slot = slots[i].val(),
          message = slots[i].data('message') || '',
          chosen = slots[i].data('slot-chosen') || false,
          originalAvailability = slots[i].attr('disabled') ? 0 : (chosen) ? 0 : 1,
          active = slots[i].is(':selected');

        day = this.splitDateAndSlot(slot)[0];

        if (active) {
          this.updateSelectedDate(day);
          this.updateSelectedSlot(slot);
        }

        // Check if this is a new date in the array and push into days
        // If not a new day then just push the timeslot
        if (previous !== day) {
          times = [];
          statuses = [];
          chosenArr = [];
          p = days.push({
            'date': day,
            'timeslots': times,
            'availability': null
          }) - 1;
          times.push({
            'day': day,
            'time': this.splitDateAndSlot(slot)[1],
            'slot': slot,
            'available': originalAvailability,
            'message': message,
            'chosen': chosen,
            'selected': active
          });
          $.each(times, function(i, obj) {
            statuses.push(obj.available);
            chosenArr.push(obj.chosen);
          });
          days[p]['availability'] = (this.getUnique(statuses).length > 1) ? 1 : statuses[0];
          days[p]['chosen'] = (this.getUnique(chosenArr).length > 1) ? true : chosenArr[0];
        } else {
          times.push({
            'day': day,
            'time': this.splitDateAndSlot(slot)[1],
            'slot': slot,
            'available': originalAvailability,
            'message': message,
            'chosen': chosen,
            'selected': active
          });
          $.each(times, function(i, obj) {
            statuses.push(obj.available);
            chosenArr.push(obj.chosen);
          });
          days[p]['availability'] = (this.getUnique(statuses).length > 1) ? 1 : statuses[0];
          days[p]['chosen'] = (this.getUnique(chosenArr).length > 1) ? true : chosenArr[0];
          p = p;
        }
        previous = day;
      }
      return days;
    },

    /**
     * Populates the datepicker grid with calendar days representing the current month
     */
    popGrid: function() {
      var numDays = this.calcNumDays(this.year, this.month),
        startWeekday = this.calcStartWeekday(this.year, this.month),
        weekday = 0,
        curDay = 1,
        rowCount = 1,
        $tbody = this.$grid.find('tbody'),
        gridCells = '\t<tr role="row" id="row0">\n';

      // clear the grid
      $tbody.empty();
      $('#msg').empty();

      // Insert the leading empty cells
      for (weekday = 0; weekday < startWeekday; weekday++) {
        gridCells += '\t\t<td class="empty">&nbsp;</td>\n';
      }

      // insert the days of the month.
      for (curDay = 1; curDay <= numDays; curDay++) {

        var cellDate, className = 'disabled',
          ariaSelected = false;

        cellDate = this.year + '-' + (this.month <= 9 ? '0' : '') + (this.month + 1) + '-' + (curDay <= 9 ? '0' : '') + curDay;

        for (var i = 0; i < this.availableSlots.length; i++) {
          if (this.availableSlots[i].date === cellDate) {
            className = (this.availableSlots[i].availability === 1) ? 'available' : 'unavailable';
            className += (this.availableSlots[i].chosen === true) ? ' chosen' : '';
          }
        }

        if (cellDate === this.selectedDate) {
          className += ' selected';
          ariaSelected = true;
        }

        gridCells += '\t\t<td id="day' + curDay + '" class="' + className + '" aria-label="' +
          curDay + ', ' + this.settings.i18n.days[weekday] + ' ' + this.settings.i18n.months[this.month] +
          ' ' + this.year + '" role="gridcell" aria-selected="' + ariaSelected + '"><span aria-label="Press the ENTER key to select the date" class="cell-date">' + curDay + '</span></td>';

        if (weekday == 6 && curDay < numDays) {
          // This was the last day of the week, close it out
          // and begin a new one
          gridCells += '\t</tr>\n\t<tr role="row" id="row' + rowCount + '">\n';
          rowCount++;
          weekday = 0;
        } else {
          weekday++;
        }
      }

      // Insert any trailing empty cells
      for (weekday; weekday < 7; weekday++) {

        gridCells += '\t\t<td class="empty">&nbsp;</td>\n';
      }

      gridCells += '\t</tr>';

      $tbody.append(gridCells);


      var maxDate = this.makeDateObj(this.findLastAvailableDay().date).getMonth() === this.month;
      var minDate = this.makeDateObj(this.findFirstAvailableDay().date).getMonth() === this.month;

      this.toggleBtnMonth(this.$next, maxDate);
      this.toggleBtnMonth(this.$prev, minDate);
    },

    findLastAvailableDay: function() {
      return this.availableSlots[this.availableSlots.length - 1];
    },

    findFirstAvailableDay: function() {
      return this.availableSlots[0];
    },

    /**
     * Shows the previous month by re-populatng the grid
     * @param  {integer} offset
     */
    showPrevMonth: function(offset) {
      // show the previous month
      if (this.month == 0) {
        this.month = 11;
        this.year--;
      } else {
        this.month--;
      }

      if (this.month != this.curMonth || this.year != this.curYear) {
        this.currentDate = false;
      } else {
        this.currentDate = true;
      }

      // populate the calendar grid
      this.popGrid();

      this.$monthObj.html(this.settings.i18n.months[this.month] + ' ' + this.year);

      // if offset was specified, set focus on the last day - specified offset
      if (offset != null) {
        var numDays = this.calcNumDays(this.year, this.month);
        var day = 'day' + (numDays - offset);

        this.$grid.attr('aria-activedescendant', day);
        $('#' + day).addClass('focus').attr('aria-selected', 'true');
      }
    },

    /**
     * Shows the next month by re-populatng the grid
     * @param  {integer}
     */
    showNextMonth: function(offset) {

      // show the next month
      if (this.month == 11) {
        this.month = 0;
        this.year++;
      } else {
        this.month++;
      }

      if (this.month != this.curMonth || this.year != this.curYear) {
        this.currentDate = false;
      } else {
        this.currentDate = true;
      }

      // populate the calendar grid
      this.popGrid();

      this.$monthObj.html(this.settings.i18n.months[this.month] + ' ' + this.year);

      // if offset was specified, set focus on the first day + specified offset
      if (offset != null) {
        var day = 'day' + offset;

        this.$grid.attr('aria-activedescendant', day);
        $('#' + day).addClass('focus').attr('aria-selected', 'true');
      }
    },

    toggleBtnMonth: function(btn, attr) {
      btn.attr('aria-hidden', attr);
    },

    /**
     * Shows the previous year by re-populatng the grid
     */
    showPrevYear: function() {

      // decrement the year
      this.year--;

      if (this.month != this.curMonth || this.year != this.curYear) {
        this.currentDate = false;
      } else {
        this.currentDate = true;
      }

      // populate the calendar grid
      this.popGrid();

      this.$monthObj.html(this.settings.i18n.months[this.month] + ' ' + this.year);
    },

    /**
     * Shows the next year by re-populatng the grid
     */
    showNextYear: function() {

      // increment the year
      this.year++;

      if (this.month != this.curMonth || this.year != this.curYear) {
        this.currentDate = false;
      } else {
        this.currentDate = true;
      }

      // populate the calendar grid
      this.popGrid();

      this.$monthObj.html(this.settings.i18n.months[this.month] + ' ' + this.year);
    },

    handlePrevClick: function(e) {

      var active = this.$grid.attr('aria-activedescendant');

      if (e.ctrlKey) {
        this.showPrevYear();
      } else {
        this.showPrevMonth();
      }

      if (this.currentDate == false) {
        this.$grid.attr('aria-activedescendant', 'day1');
      } else {
        this.$grid.attr('aria-activedescendant', active);
      }

      e.stopPropagation();
      return false;
    },

    handleNextClick: function(e) {

      var active = this.$grid.attr('aria-activedescendant');

      if (e.ctrlKey) {
        this.showNextYear();
      } else {
        this.showNextMonth();
      }

      if (this.currentDate == false) {
        this.$grid.attr('aria-activedescendant', 'day1');
      } else {
        this.$grid.attr('aria-activedescendant', active);
      }

      e.stopPropagation();
      return false;
    },

    handlePrevKeyDown: function(e) {

      if (e.altKey) {
        return true;
      }

      switch (e.keyCode) {
        case this.keys.tab:
          {
            if (this.bModal == false || !e.shiftKey || e.ctrlKey) {
              return true;
            }

            this.$grid.focus();
            e.stopPropagation();
            return false;
          }
        case this.keys.enter:
        case this.keys.space:
          {
            if (e.shiftKey) {
              return true;
            }

            if (e.ctrlKey) {
              this.showPrevYear();
            } else {
              this.showPrevMonth();
            }

            e.stopPropagation();
            return false;
          }
      }

      return true;
    },

    handleNextKeyDown: function(e) {

      if (e.altKey) {
        return true;
      }

      switch (e.keyCode) {
        case this.keys.enter:
        case this.keys.space:
          {

            if (e.ctrlKey) {
              this.showNextYear();
            } else {
              this.showNextMonth();
            }

            e.stopPropagation();
            return false;
          }
      }

      return true;
    },

    handleGridKeyDown: function(e) {

      var $rows = this.$grid.find('tbody tr');
      var $curDay = $('#' + this.$grid.attr('aria-activedescendant'));
      var $days = this.$grid.find('td').not('.empty');
      var $emptyDays = this.$grid.find('td').not('.empty, .disabled');
      var $curRow = $curDay.parent();

      if (e.altKey) {
        return true;
      }

      switch (e.keyCode) {

        case this.keys.enter:
        case this.keys.space:
          {

            if (e.ctrlKey) {
              return true;
            }

            var dayIndex = $emptyDays.index($curDay);

            if (dayIndex >= 0) {
              this.$grid.find('.selected').removeClass('selected').attr('aria-selected', 'false');
              $curDay.addClass('selected').attr('aria-selected', 'true').find('.cell-date');
              // update the target box
              var date = this.year + '-' + (this.month < 9 ? '0' : '') + (this.month + 1) + '-' + ($curDay.text() <= 9 ? '0' : '') + $curDay.text();
              this.updateSelectedDate(date);
              this.updateSlots(date);
              this.$slotList.find('input').eq(0).focus();
            } else {
              return false;
            }

            // fall through
          }
        case this.keys.esc:
          {
            e.stopPropagation();
            return false;
          }
        case this.keys.left:
          {

            if (e.ctrlKey || e.shiftKey) {
              return true;
            }

            var dayIndex = $days.index($curDay) - 1;
            var $prevDay = null;

            if (dayIndex >= 0) {
              $prevDay = $days.eq(dayIndex);

              $curDay.removeClass('focus').attr('aria-selected', 'false');
              $prevDay.addClass('focus').attr('aria-selected', 'true');

              this.$grid.attr('aria-activedescendant', $prevDay.attr('id'));
            } else {
              this.showPrevMonth(0);
            }

            e.stopPropagation();
            return false;
          }
        case this.keys.right:
          {

            if (e.ctrlKey || e.shiftKey) {
              return true;
            }

            var dayIndex = $days.index($curDay) + 1;
            var $nextDay = null;

            if (dayIndex < $days.length) {
              $nextDay = $days.eq(dayIndex);
              $curDay.removeClass('focus').attr('aria-selected', 'false');
              $nextDay.addClass('focus').attr('aria-selected', 'true');

              this.$grid.attr('aria-activedescendant', $nextDay.attr('id'));
            } else {
              // move to the next month
              this.showNextMonth(1);
            }

            e.stopPropagation();
            return false;
          }
        case this.keys.up:
          {

            if (e.ctrlKey || e.shiftKey) {
              return true;
            }

            var dayIndex = $days.index($curDay) - 7;
            var $prevDay = null;

            if (dayIndex >= 0) {
              $prevDay = $days.eq(dayIndex);

              $curDay.removeClass('focus').attr('aria-selected', 'false');
              $prevDay.addClass('focus').attr('aria-selected', 'true');

              this.$grid.attr('aria-activedescendant', $prevDay.attr('id'));
            } else {
              // move to appropriate day in previous month
              dayIndex = 6 - $days.index($curDay);

              this.showPrevMonth(dayIndex);
            }

            e.stopPropagation();
            return false;
          }
        case this.keys.down:
          {

            if (e.ctrlKey || e.shiftKey) {
              return true;
            }

            var dayIndex = $days.index($curDay) + 7;
            var $prevDay = null;

            if (dayIndex < $days.length) {
              $prevDay = $days.eq(dayIndex);

              $curDay.removeClass('focus').attr('aria-selected', 'false');
              $prevDay.addClass('focus').attr('aria-selected', 'true');

              this.$grid.attr('aria-activedescendant', $prevDay.attr('id'));
            } else {
              // move to appropriate day in next month
              dayIndex = 8 - ($days.length - $days.index($curDay));

              this.showNextMonth(dayIndex);
            }

            e.stopPropagation();
            return false;
          }
        case this.keys.pageup:
          {
            var active = this.$grid.attr('aria-activedescendant');


            if (e.shiftKey) {
              return true;
            }


            if (e.ctrlKey) {
              this.showPrevYear();
            } else {
              this.showPrevMonth();
            }

            if ($('#' + active).attr('id') == undefined) {
              var lastDay = 'day' + this.calcNumDays(this.year, this.month);
              $('#' + lastDay).addClass('focus').attr('aria-selected', 'true');
            } else {
              $('#' + active).addClass('focus').attr('aria-selected', 'true');
            }

            e.stopPropagation();
            return false;
          }
        case this.keys.pagedown:
          {
            var active = this.$grid.attr('aria-activedescendant');


            if (e.shiftKey) {
              return true;
            }

            if (e.ctrlKey) {
              this.showNextYear();
            } else {
              this.showNextMonth();
            }

            if ($('#' + active).attr('id') == undefined) {
              var lastDay = 'day' + this.calcNumDays(this.year, this.month);
              $('#' + lastDay).addClass('focus').attr('aria-selected', 'true');
            } else {
              $('#' + active).addClass('focus').attr('aria-selected', 'true');
            }

            e.stopPropagation();
            return false;
          }
        case this.keys.home:
          {

            if (e.ctrlKey || e.shiftKey) {
              return true;
            }

            $curDay.removeClass('focus').attr('aria-selected', 'false');

            $('#day1').addClass('focus').attr('aria-selected', 'true');

            this.$grid.attr('aria-activedescendant', 'day1');

            e.stopPropagation();
            return false;
          }
        case this.keys.end:
          {

            if (e.ctrlKey || e.shiftKey) {
              return true;
            }

            var lastDay = 'day' + this.calcNumDays(this.year, this.month);

            $curDay.removeClass('focus').attr('aria-selected', 'false');

            $('#' + lastDay).addClass('focus').attr('aria-selected', 'true');

            this.$grid.attr('aria-activedescendant', lastDay);

            e.stopPropagation();
            return false;
          }
      }

      return true;
    },

    handleGridKeyPress: function(e) {

      if (e.altKey) {
        return true;
      }

      switch (e.keyCode) {
        case this.keys.enter:
        case this.keys.space:
        case this.keys.esc:
        case this.keys.left:
        case this.keys.right:
        case this.keys.up:
        case this.keys.down:
        case this.keys.pageup:
        case this.keys.pagedown:
        case this.keys.home:
        case this.keys.end:
          {
            e.stopPropagation();
            return false;
          }
      }

      return true;
    },

    handleGridClick: function(id, e) {
      var $cell = $(id);

      if ($cell.is('.empty')) {
        return true;
      }

      this.$grid.find('.focus, .selected').removeClass('focus selected').attr('aria-selected', 'false');
      $cell.addClass('focus selected').attr('aria-selected', 'true').find('.cell-date');
      this.$grid.attr('aria-activedescendant', $cell.attr('id'));

      var $curDay = $('#' + this.$grid.attr('aria-activedescendant'));

      // update the target box
      var date = this.year + '-' + (this.month <= 9 ? '0' : '') + (this.month + 1) + '-' + ($curDay.text() <= 9 ? '0' : '') + $curDay.text();
      this.updateSelectedDate(date);
      this.updateSlots(date);

      e.stopPropagation();
      return false;
    },

    handleGridFocus: function(e) {
      var active = this.$grid.attr('aria-activedescendant');

      if ($('#' + active).attr('id') == undefined) {
        var lastDay = 'day1';
        $('#' + lastDay).addClass('focus').attr('aria-selected', 'true');
        this.$grid.attr('aria-activedescendant', 'day1');
      } else {
        $('#' + active).addClass('focus').attr('aria-selected', 'true');
      }

      return true;
    },

    handleGridBlur: function(e) {
      $('#' + this.$grid.attr('aria-activedescendant')).removeClass('focus').attr('aria-selected', 'false');

      return true;
    },

    updateSelectedDate: function(date) {
      this.selectedDate = date;
    },

    updateSelectedSlot: function(slot) {
      this.selectedSlot = slot;
    },

    updateSource: function(slot) {
      this.$slotSource.val(slot);
    },

    updateSlots: function(date) {
      var self = this,
        $list = $(document.createElement('div'));

      var slot = $.map(this.availableSlots, function(n, i) {
        if (n.date === date) {
          return n.timeslots;
        };
      });

      $.each(slot, function(i, obj) {
        var className = '',
          time = self.formatTime(obj.time.split('/')[0]),
          duration = self.formatTimeDuration(obj.time),
          disabled,
          checked = obj.slot === self.selectedSlot ? 'checked' : null;

        if (!checked) {
          className += obj.chosen === true ? ' chosen' : '';
          className += obj.available === 0 ? ' disabled' : '';
          disabled = (obj.chosen === true || obj.available === 0) ? 'disabled' : null;
        }

        var tmpl = '<label class="block-label selection-button-radio slot' + className + '" for="slot-step-' + obj.day + '-' + i + '">' +
          '<input ' + checked + ' aria-label="Choose time slot ' + time + ' for ' + duration + '" ' + disabled + ' id="slot-step-' + obj.day + '-' + i + '" type="radio" name="slot_step_0" value="' + obj.slot + '">' +
          '<span class="slot--time">' + time + ' (' + duration + ')</span>' +
          '<br/>' +
          '<span class="slot--message">' + obj.message + '</span>' +
          '</label>';
        $list.append(tmpl);
      });

      this.$slotList.html($list);

      var inputs = $("label input[type='radio']").length;

      if (inputs > 0) {
        var selectionButtons = new GOVUK.SelectionButtons("label input[type='radio']");
      }
    },

    handleSlotChosen: function() {
      var html = '';

      if (this.selectedSlot) {
        var dateObj = this.formatSlot(this.selectedSlot);

        this.$slotTarget.find('.date-box__day').text(dateObj.day + ' ' + dateObj.formattedDate);
        this.$slotTarget.find('.date-box__slot').text(dateObj.time + ' (' + dateObj.duration + ')');
      } else {
        this.$slotTarget.find('.date-box__day').text('');
        this.$slotTarget.find('.date-box__slot').text('');
      }

      this.$slotTarget.attr('aria-hidden', false);
    },

    removeSlot: function() {

      this.$slotSource.find('option:selected').prop("selected", false).data('message', null).data('slot-chosen', null);
      this.$slotSource.val(null);
      this.$slotList.empty();
      // debugger;
      this.availableSlots = this.getAvailableSlots();
      this.selectedSlot = null;
      this.selectedDate = null;
      this.popGrid();
      this.handleSlotChosen();
    },

    formatSlot: function(slot) {
      var date = this.makeDateObj(this.splitDateAndSlot(slot)[0]),
        time = this.splitDateAndSlot(slot)[1];
      return {
        'day': this.settings.i18n.days[date.getDay()],
        'date': {
          'day': date.getDate(),
          'monthIndex': date.getMonth(),
          'year': date.getFullYear()
        },
        'formattedDate': date.getDate() + ' ' + this.settings.i18n.months[date.getMonth()],
        'time': this.formatTime(time.split('/')[0]),
        'duration': this.formatTimeDuration(time)
      }
    },

    calcNumDays: function(year, month) {
      return 32 - new Date(year, month, 32).getDate();
    },

    calcStartWeekday: function(year, month) {
      return new Date(year, month, 1).getDay();
    },

    splitDateAndSlot: function(str) {
      return str.split('T');
    },

    formatTime: function(time) {
      var hours = time.split(':')[0],
        minutes = time.split(':')[1],
        ampm = hours >= 12 ? 'pm' : 'am';
      hours = hours % 12;
      hours = hours ? hours : 12;
      var strTime = hours + ':' + minutes + '' + ampm;
      return strTime;
    },

    formatTimeDuration: function(time) {
      return this.duration(this.timeFromSlot(time.split('/')[0]), this.timeFromSlot(time.split('/')[1]));
    },

    timeFromSlot: function(slot) {
      var time = new Date();

      time.setHours(slot.split(':')[0]);
      time.setMinutes(slot.split(':')[1]);

      return time;
    },

    makeDateObj: function(date) {
      var dateArr = date.split('-');
      return new Date(dateArr[0], parseInt(dateArr[1]) - 1, dateArr[2]);
    },

    duration: function(start, end) {
      var out = '',
        diff = end.getTime() - start.getTime(),
        duration = new Date(diff);

      if (duration.getUTCHours()) {
        out += duration.getUTCHours() + ' ';
        if (duration.getUTCHours() > 1) {
          out += this.settings.i18n.hour.other;
        } else {
          out += this.settings.i18n.hour.one;
        }
      }

      if (duration.getMinutes()) {
        out += ' ' + duration.getMinutes() + ' ';
        if (duration.getMinutes() > 1) {
          out += this.settings.i18n.minute.other;
        } else {
          out += this.settings.i18n.minute.one;
        }
      }

      return out;
    },

    ordinal_suffix_of: function(i) {
      var j = i % 10,
        k = i % 100;
      if (j == 1 && k != 11) {
        return i + "st";
      }
      if (j == 2 && k != 12) {
        return i + "nd";
      }
      if (j == 3 && k != 13) {
        return i + "rd";
      }
      return i + "th";
    }

  };

}());