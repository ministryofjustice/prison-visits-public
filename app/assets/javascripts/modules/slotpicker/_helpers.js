(function() {
  'use strict';

  moj.Modules.Slotpicker = moj.Modules.Slotpicker || {}

  moj.Modules.Slotpicker.Helpers = {

    el: '.js-calendar',

    i18n: {},

    init: function() {
      if ($(this.el) && $(this.el).length > 0) {
        this.cacheEls();
      }
    },

    cacheEls: function() {
      this.$el = $(this.el);
      this.i18n = this.$el.data('i18n');
    },

    calcDaysInMonth: function(year, month) {
      return 32 - new Date(year, month, 32).getDate();
    },

    calcStartWeekday: function(year, month) {
      return new Date(year, month, 1).getDay();
    },

    duration: function(start, end) {
      var out = '',
        diff = end.getTime() - start.getTime(),
        duration = new Date(diff);
      if (duration.getUTCHours()) {
        out += duration.getUTCHours() + ' ';
        out += (duration.getUTCHours() > 1)? this.i18n.hour.other :this.i18n.hour.one;
      }
      if (duration.getMinutes()) {
        out += ' ' + duration.getMinutes() + ' ';
        out += (duration.getMinutes() > 1)? this.i18n.minute.other :this.i18n.minute.one;
      }
      return out;
    },

    formatSlot: function(slot) {
      var date = this.makeDateObj(this.splitDateAndSlot(slot)[0]),
        time = this.splitDateAndSlot(slot)[1];
      return {
        'day': this.i18n.days[date.getDay()],
        'date': {
          'day': date.getDate(),
          'monthIndex': date.getMonth(),
          'year': date.getFullYear()
        },
        'formattedDate': date.getDate() + ' ' + this.i18n.months[date.getMonth()],
        'time': this.formatTime(this.splitTime(time)[0]),
        'duration': this.formatTimeDuration(time)
      }
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
      return this.duration(this.timeFromSlot(this.splitTime(time)[0]), this.timeFromSlot(this.splitTime(time)[1]));
    },

    timeFromSlot: function(slot) {
      var time = new Date();
      time.setHours(slot.split(':')[0]);
      time.setMinutes(slot.split(':')[1]);
      return time;
    },

    getUnique: function(arr) {
      var unique = [];
      for (var i = 0; i < arr.length; i++) {
        if ((jQuery.inArray(arr[i], unique)) == -1) {
          unique.push(arr[i]);
        }
      }
      return unique;
    },

    makeDateObj: function(date) {
      var arr = date.split('-');
      return new Date(arr[0], parseInt(arr[1], 10) - 1, arr[2]);
    },

    splitDateAndSlot: function(str) {
      return str.split('T');
    },

    splitTime: function(time) {
      return time.split('/');
    },

    setFocus: function(el) {
      el.addClass('focus').find('.cell-date').attr('aria-selected', 'true');
    },

    unsetFocus: function(el) {
      el.removeClass('focus').find('.cell-date').attr('aria-selected', 'false');
    },

    conditionals: function(string) {
      return $(string ? '#' + string.split(',').join(',#') : null);
    }

  }

}());
