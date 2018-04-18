(function() {
  'use strict';

  moj.Modules.Slotpicker = moj.Modules.Slotpicker || {}

  var Calendar = function(el, options) {
    this._settings = $.extend({}, this.defaults, options);
    this.init = function() {
      this.cacheEls();
      this.bindEvents();
      this.makeGrid();
    };
    this.cacheEls = function() {
      this.$el = el;
      this.$grid = this.$el.find('#js-calendarTable');
      this.$tbody = this.$grid.find('tbody');
      this.$monthHeader = this.$el.find('#month');
      this.$prev = this.$el.find('#bn_prev');
      this.$next = this.$el.find('#bn_next');
    };
    return this;
  }

  Calendar.prototype = {

    defaults: {
      keys: {
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
      },
      JANUARY: 0,
      DECEMBER: 11
    },

    bindEvents: function() {
      var self = this;
      this.$prev.click(function(e) {return self.handleNavClick(e, 'prev');});
      this.$next.click(function(e) {return self.handleNavClick(e, 'next');});
      this.$prev.keydown(function(e) {return self.handleNavKeyDown(e, 'prev');});
      this.$next.keydown(function(e) {return self.handleNavKeyDown(e, 'next');});
      this.$grid.keydown(function(e) {return self.handleGridKeyDown(e);});
      this.$grid.keypress(function(e) {return self.handleGridKeyPress(e);});
      this.$grid.focus(function(e) {return self.handleGridFocus(e);});
      this.$grid.blur(function(e) {return self.handleGridBlur(e);});
      this.$grid.delegate('td', 'click', function(e) {return self.handleGridClick(this, e);});
    },

    makeGrid: function() {
      var numDays = moj.Modules.Slotpicker.Helpers.calcDaysInMonth(this._settings.year, this._settings.month),
          startWeekday = moj.Modules.Slotpicker.Helpers.calcStartWeekday(this._settings.year, this._settings.month),
          weekday, rowCount = 1, $tr = this.makeRow(0);

      this.$monthHeader.html(this._settings.i18n.months[this._settings.month] + ' ' + this._settings.year);
      this.clearGrid();
      for (weekday = 0; weekday < startWeekday; weekday++) {
        $tr.append(this.makeCell(null, 'empty'));
      }
      for (var curDay = 1; curDay <= numDays; curDay++) {
        var attrs = this.buildAttrs(this.cellDate(curDay)),
            $td = this.makeCell(curDay, attrs.className);

        $td.append(this.buildAnchor(curDay, weekday, attrs)).appendTo($tr);

        if (weekday == 6 && curDay < numDays) {
          this.addRows($tr);
          $tr = this.makeRow(rowCount);
          rowCount++;
          weekday = 0;
        } else {
          weekday++;
        }
      }
      this.addRows($tr);
      this.setPrevBtn();
      this.setNextBtn();
    },

    makeRow: function(num) {
      return $('<tr/>').attr('role', 'row').attr('id', 'row'+num);
    },

    makeCell: function(day, className) {
      return $('<td/>').attr('id', 'day'+day)
              .attr('role', 'gridcell')
              .addClass(className);
    },

    cellDate: function(day) {
      return this._settings.year + '-' + (this._settings.month <= 8 ? '0' : '') + (this._settings.month + 1) + '-' + (day <= 9 ? '0' : '') + day;
    },

    buildAttrs: function(date) {
      var attrs = {
        day: date,
        className: 'disabled',
        ariaSelected: this.isSelected(date) || false,
        ariaLabel: ' - This date is unavailable',
        readonly: true
      };
      for(var i = 0; i<this._settings.availableSlots.length; i++) {
        if (this.isSlotDate(i,date)) {
          attrs.className = this.isAvailableDate(i)
            ? 'available' + this.chosenDate(i)
            : 'unavailable';
          attrs.className += this.isSelected(date)? ' selected' : '';
          attrs.readonly = this.isAvailableDate(i)? false : true;
          attrs.ariaLabel = '';
        }
      }
      return attrs;
    },

    isSlotDate: function(i, date) {
      return this._settings.availableSlots[i].date === date;
    },

    isSelected: function(date) {
      return this._settings.selectedDate === date;
    },

    isAvailableDate: function(i) {
      return this._settings.availableSlots[i].availability === 1;
    },

    chosenDate: function(i) {
      return this._settings.availableSlots[i].chosen === true
        ? ' chosen'
        : ''
    },

    buildAnchor: function(curDay, weekday, attrs) {
      var ariaLabel = curDay + ', ' + this._settings.i18n.days[weekday] + ' ' + this._settings.i18n.months[this._settings.month] + ' ' + this._settings.year + attrs.ariaLabel;
      return $('<a/>').text(curDay).addClass('cell-date no-link')
              .attr('href', '#').attr('rel', 'nofollow')
              .attr('aria-label', ariaLabel)
              .attr('aria-readonly', attrs.readonly)
              .attr('aria-selected', attrs.ariaSelected)
              .attr('tabindex', '-1');
    },

    clearGrid: function() {
      this.$tbody.empty();
    },

    addRows: function(html) {
      this.$tbody.append(html);
    },

    hideNavBtn: function(btn, attr) {
      btn.attr('aria-hidden', attr);
    },

    setPrevBtn: function() {
      var maxDate = moj.Modules.Slotpicker.Helpers.makeDateObj(this.findLastAvailableDay().date).getMonth();
      if(this._settings.month == this._settings.DECEMBER && maxDate == this._settings.JANUARY){
        this.hideNavBtn(this.$next, false);
      } else if(maxDate > this._settings.month) {
        this.hideNavBtn(this.$next, false);
      } else {
        this.hideNavBtn(this.$next, true);
      }
    },

    setNextBtn: function() {
      var minDate = moj.Modules.Slotpicker.Helpers.makeDateObj(this.findFirstAvailableDay().date).getMonth();
      if(this._settings.month == this._settings.JANUARY && minDate == this._settings.DECEMBER){
        this.hideNavBtn(this.$prev, false);
      } else if(minDate < this._settings.month) {
        this.hideNavBtn(this.$prev, false);
      } else {
        this.hideNavBtn(this.$prev, true);
      }
    },

    findLastAvailableDay: function() {
      return this._settings.availableSlots[this._settings.availableSlots.length - 1];
    },

    findFirstAvailableDay: function() {
      return this._settings.availableSlots[0];
    },

    showPrevMonth: function(offset) {
      if (this._settings.month == this._settings.JANUARY) {
        this._settings.month = this._settings.DECEMBER;
        this._settings.year--;
      } else {
        this._settings.month--;
      }
      this.setMonth();
      // if offset was specified, set focus on the last day - specified offset
      if (offset != null) {
        var numDays = moj.Modules.Slotpicker.Helpers.calcDaysInMonth(this._settings.year, this._settings.month);
        var day = 'day' + (numDays - offset);
        this.setDayAttr(day);
      }
    },

    showNextMonth: function(offset) {
      if (this._settings.month == this._settings.DECEMBER) {
        this._settings.month = this._settings.JANUARY;
        this._settings.year++;
      } else {
        this._settings.month++;
      }
      this.setMonth();
      // if offset was specified, set focus on the first day + specified offset
      if (offset != null) {
        var day = 'day' + offset;
        this.setDayAttr(day);
      }
    },

    setMonth: function() {
      this.setCurrentDate();
      this.makeGrid();
    },

    setDayAttr: function(day) {
      this.setActiveDescendant(day);
      this.addCellFocus($('#' + day));
    },

    setCurrentDate: function() {
      if (this._settings.month != this._settings.curMonth || this._settings.year != this._settings.curYear) {
        this._settings.currentDate = false;
      } else {
        this._settings.currentDate = true;
      }
    },

    handleNavClick: function(e, direction) {
      var active = this.getActiveDescendant();
      (direction == 'next')? this.showNextMonth() : this.showPrevMonth();
      if (this._settings.currentDate == false) {
        this.setActiveDescendant('day1');
      } else {
        this.setActiveDescendant(active);
      }
      return this.keyPressStop(e)
    },

    handleNavKeyDown: function(e, direction) {
      if (e.altKey) {
        return true;
      }
      switch (e.keyCode) {
        case this._settings.keys.tab: {
          if (e.shiftKey || e.ctrlKey) {
            return true;
          }
          this.$grid.focus();
          return this.keyPressStop(e)
        }
        case this._settings.keys.enter:
        case this._settings.keys.space: {
          (direction == 'next')? this.showNextMonth() : this.showPrevMonth();
          return this.keyPressStop(e)
        }
      }
    },

    handleGridFocus: function(e) {
      var active = this.getActiveDescendant();
      if (!active || active == 'month') {
        this.setFirstDayFocus();
      } else {
        this.addCellFocus($('#' + active));
      }
      return true;
    },

    handleGridBlur: function(e) {
      this.removeCellFocus(moj.Modules.Slotpicker.Helpers.conditionals(this.getActiveDescendant()));
      return true;
    },

    handleGridKeyDown: function(e) {
      this.removeCellFocus(moj.Modules.Slotpicker.Helpers.conditionals(this.getActiveDescendant()));
      if (e.altKey || e.ctrlKey || e.shiftKey) {
        return true;
      }
      switch (e.keyCode) {
        case this._settings.keys.enter:
        case this._settings.keys.space: {
          return this.keyPressEnter(e)
        }
        case this._settings.keys.esc: {
          return this.keyPressStop(e)
        }
        case this._settings.keys.left:
        case this._settings.keys.right: {
          return this.keyPressLeftRight(e)
        }
        case this._settings.keys.up:
        case this._settings.keys.down: {
          return this.keyPressUpDown(e);
        }
        case this._settings.keys.pageup:
        case this._settings.keys.pagedown: {
          (e.keyCode == this._settings.keys.pageup)? this.showPrevMonth() : this.showNextMonth()
          return this.keyPressPageUpDown(e)
        }
        case this._settings.keys.home:
        case this._settings.keys.end: {
          return this.keyPressHomeEnd(e);
        }
      }
      return true;
    },

    keyPressStop: function(e) {
      e.stopPropagation();
      return false;
    },

    keyPressEnter: function(e) {
      var $curDay = moj.Modules.Slotpicker.Helpers.conditionals(this.getActiveDescendant()),
          $emptyDays = this.$grid.find('td').not('.empty, .disabled'),
          dayIndex = $emptyDays.index($curDay);
      this.$grid.find('.selected').removeClass('focus selected').find('.cell-date').attr('aria-selected', 'false');
      $curDay.addClass('focus selected').find('.cell-date').attr('aria-selected', 'true');
      if (dayIndex >= 0) {
        this.updateSelected($curDay);
        this.sendAnalytics('Keydown', this._settings.availableMessage);
      } else {
        this.setUnavailableMessage();
        this.sendAnalytics('Keydown', this._settings.unavailableMessage);
        return this.keyPressStop(e)
      }
    },

    keyPressLeftRight: function(e, dir) {
      var $curDay = moj.Modules.Slotpicker.Helpers.conditionals(this.getActiveDescendant()),
          $days = this.$grid.find('td').not('.empty'),
          dayIndex = (e.keyCode === this._settings.keys.left)? $days.index($curDay) - 1 : $days.index($curDay) + 1;
      if (dayIndex >= 0 && dayIndex < $days.length) {
        var $newDay = $days.eq(dayIndex);
        this.addCellFocus($newDay);
        this.setActiveDescendant($newDay.attr('id'));
      } else {
        (e.keyCode === this._settings.keys.left)? this.showPrevMonth(0) : this.showNextMonth(1);
      }
      return this.keyPressStop(e)
    },

    keyPressUpDown: function(e) {
      var $curDay = moj.Modules.Slotpicker.Helpers.conditionals(this.getActiveDescendant()),
          $days = this.$grid.find('td').not('.empty'),
          offset = (e.keyCode === this._settings.keys.up)? -7 : +7,
          dayIndex = $days.index($curDay) + offset;
      if (dayIndex >= 0 && dayIndex < $days.length) {
        var $newDay = $days.eq(dayIndex);
        this.addCellFocus($newDay);
        this.setActiveDescendant($newDay.attr('id'));
      } else {
        dayIndex = (e.keyCode === this._settings.keys.up)? 6 - $days.index($curDay) : 8 - ($days.length - $days.index($curDay));
        (e.keyCode === this._settings.keys.up)? this.showPrevMonth(dayIndex) : this.showNextMonth(dayIndex);
      }
      return this.keyPressStop(e)
    },

    keyPressPageUpDown: function(e) {
      var active = this.getActiveDescendant();
      if (!active || active == 'month') {
        this.setLastDayFocus()
      } else {
        this.addCellFocus($('#' + active));
        this.setActiveDescendant(active);
      }
      return this.keyPressStop(e)
    },

    keyPressHomeEnd: function(e) {
      (e.keyCode === this._settings.keys.home)? this.setFirstDayFocus() : this.setLastDayFocus();
      return this.keyPressStop(e)
    },

    handleGridKeyPress: function(e) {
      if (e.altKey) {
        return true;
      }
      switch (e.keyCode) {
        case this._settings.keys.enter:
        case this._settings.keys.space:
        case this._settings.keys.esc:
        case this._settings.keys.left:
        case this._settings.keys.right:
        case this._settings.keys.up:
        case this._settings.keys.down:
        case this._settings.keys.pageup:
        case this._settings.keys.pagedown:
        case this._settings.keys.home:
        case this._settings.keys.end:
          {
            return this.keyPressStop(e)
          }
      }
      return true;
    },

    handleGridClick: function(id, e) {
      var $cell = $(id);
      if ($cell.is('.empty')) {
        return true;
      }
      this.$grid.find('.focus, .selected').removeClass('focus selected').find('.cell-date').attr('aria-selected', 'false');
      $cell.addClass('focus selected').find('.cell-date').attr('aria-selected', 'true');
      this.setActiveDescendant($cell.attr('id'));

      if ($cell.is('.disabled')) {
        this.setUnavailableMessage();
        this.sendAnalytics('Click', this._settings.unavailableMessage);
        return true;
      }
      var $curDay = $('#' + this.getActiveDescendant());
      this.updateSelected($curDay);
      this.sendAnalytics('Click', this._settings.availableMessage);
      return this.keyPressStop(e)
    },

    setFirstDayFocus: function() {
      this.addCellFocus($('#day1'));
      this.setActiveDescendant('day1');
    },

    setLastDayFocus: function() {
      var lastDay = 'day' + moj.Modules.Slotpicker.Helpers.calcDaysInMonth(this._settings.year, this._settings.month);
      this.addCellFocus(moj.Modules.Slotpicker.Helpers.conditionals(lastDay));
      this.setActiveDescendant(lastDay);
    },

    getActiveDescendant: function() {
      return this.$grid.attr('aria-activedescendant');
    },

    setActiveDescendant: function(val) {
      this.$grid.attr('aria-activedescendant', val);
    },

    addCellFocus: function($cell) {
      $cell.addClass('focus').find('.cell-date').attr('aria-selected', 'true');
    },

    removeCellFocus: function($cell) {
      $cell.removeClass('focus').find('.cell-date').attr('aria-selected', 'false');
    },

    setUnavailableMessage: function() {
      moj.Modules.Slotpicker.Helpers.conditionals(this._settings.slotList).html(this._settings.unavailableMessage);
    },

    updateSelected: function($curDay) {
      var date = this._settings.year + '-' + (this._settings.month < 9 ? '0' : '') + (this._settings.month + 1) + '-' + ($curDay.text() <= 9 ? '0' : '') + $curDay.text();
      this._settings.selectedDate = date;
      this.$el.trigger('updateSlotsList', date);
    },

    sendAnalytics: function(action, label) {
      moj.Modules.Analytics.send({
        'category': 'Calendar',
        'action': action,
        'label': label
      });
    }

  }

  moj.Modules.Slotpicker.Calendar = Calendar;

}());
