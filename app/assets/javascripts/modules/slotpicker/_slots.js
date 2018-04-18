(function() {
  'use strict';

  moj.Modules.Slotpicker = moj.Modules.Slotpicker || {}

  var Slots = function(el, date, options) {
    this.$el = el;
    this.dateChosen = date;
    this._settings = $.extend({}, this.defaults, options);
    this.init = function() {
      this.cacheEls();
      this.bindEvents();
      this.updateSlots();
    };

    return this;
  }

  Slots.prototype = {

    defaults: {
      selectedSlot: null
    },

    cacheEls: function() {
      this.$slotList = moj.Modules.Slotpicker.Helpers.conditionals(this._settings.slotList);
      this.$slotTarget = moj.Modules.Slotpicker.Helpers.conditionals(this._settings.slotTarget);
    },

    bindEvents: function() {
      var self = this;
      this.$slotList.on('change', 'input[type=radio][name=slot_step_0]', function(e) {
        self._settings.selectedSlot = $(e.currentTarget).val();
        self.$el.trigger('updateSelectedSlot', self._settings.selectedSlot);
        self.handleSlotChosen();
      });
    },

    updateSlots: function() {
      var self = this,
        $list = $(document.createElement('div')),
        slots = this.buildSlotTimes();

      $.each(slots, function(i, obj) {
        var slot = {
          className: '',
          selectedDate: moj.Modules.Slotpicker.Helpers.formatSlot(obj.slot),
          time: moj.Modules.Slotpicker.Helpers.formatTime(obj.time.split('/')[0]),
          duration: moj.Modules.Slotpicker.Helpers.formatTimeDuration(obj.time),
          disabled: null,
          checked: function(){
            return obj.slot === self._settings.selectedSlot ? 'checked' : ''
          }
        };
        if (!slot.checked()) {
          slot.className += obj.chosen === true ? ' chosen' : '';
          slot.className += obj.available === 0 ? ' disabled' : '';
          slot.disabled = (obj.chosen === true || obj.available === 0) ? 'disabled' : '';
        }
        $list.append(self.buildSlotRadio(i, slot, obj));
      });
      this.$slotList.html($list);
    },

    buildSlotTimes: function() {
      var self = this;
      return $.map(this._settings.availableSlots, function(n, i) {
        if (n.date === self.dateChosen) {
          return n.timeslots;
        };
      });
    },

    buildSlotRadio: function(i, slot, obj) {
      return '<div class="multiple-choice">' +
        '<input ' + slot.checked + ' ' + slot.disabled + ' id="slot-step-' + obj.day + '-' + i + '" type="radio" name="slot_step_0" value="' + obj.slot + '">' +
        '<label class="selection-button-radio slot' + slot.className + '" for="slot-step-' + obj.day + '-' + i + '">' +
        '<span class="slot--time">' + slot.time + ' (' + slot.duration + ')</span>' +
        '<br/>' +
        '<span class="slot--message">' + obj.message + '</span>' +
        '</label>' +
        '</div>';
    },

    handleSlotChosen: function() {
      if (this._settings.selectedSlot) {
        var dateObj = moj.Modules.Slotpicker.Helpers.formatSlot(this._settings.selectedSlot);
        this.buildDateBox(dateObj.day + ' ' + dateObj.formattedDate, dateObj.time + ' (' + dateObj.duration + ')');
      } else {
        this.buildDateBox(null, null);
      }
      this.$slotTarget.attr('aria-hidden', false);
    },

    buildDateBox: function(day, slot) {
      this.$slotTarget.find('.date-box__day').text(day)
      this.$slotTarget.find('.date-box__slot').text(slot)
    }

  };

  moj.Modules.Slotpicker.Slots = Slots;

}());
