(function() {
  'use strict';

  moj.Modules.Slotpicker = moj.Modules.Slotpicker || {}

  var Datepicker = function(el, options) {

    this.$el = el;

    this.init = function() {
      moj.Modules.Slotpicker.SlotSource.init();
      this.previouslySelectedSlot = moj.Modules.Slotpicker.SlotSource.getValue();
      var availableSlots = moj.Modules.Slotpicker.SlotSource.getAvailableSlots(),
          firstDate = availableSlots[0].date.split('-');

      this.defaults = {
        curYear: firstDate[0],
        year: firstDate[0],
        curMonth: new Date(firstDate[0], parseInt(firstDate[1], 10) - 1, firstDate[2]).getMonth(),
        month: new Date(firstDate[0], parseInt(firstDate[1], 10) - 1, firstDate[2]).getMonth(),
        currentDate: false,
        availableSlots: availableSlots
      }

      this._settings = $.extend({}, this.defaults, options);
      this.setup();
    };

    return this;

  };

  Datepicker.prototype = {

    cacheEls: function() {
      this.$submitBtn = $('#' + this._settings.slotSubmit);
      this.$cancelBtn = $('#' + this._settings.slotCancel);
      this.$deleteBtn = $('#' + this._settings.slotDelete);
      this.$skipBtn = $('#' + this._settings.slotSkip);
      this.$skipInput = $('#' + this._settings.skipInput);
    },

    bindEvents: function() {
      var self = this;

      this.$cancelBtn.on('click', function(e) {
        e.preventDefault();
        e.stopPropagation();
        self.updateSlotSource(self.previouslySelectedSlot);
        var form = $(this).parents('form');
        form.submit();
      });

      this.$deleteBtn.on('click', function(e) {
        e.preventDefault();
        e.stopPropagation();
        moj.Modules.Slotpicker.SlotSource.removeSlot();
        var form = $(this).parents('form');
        form.submit();
      });

      this.$skipBtn.on('click', function(e) {
        e.preventDefault();
        e.stopPropagation();
        var form = $(this).parents('form');
        self.$skipInput.val(true);
        form.submit();
      });

    },

    setup: function() {
      this.cacheEls();
      this.bindEvents();
      this.setupCalendar();
      (this._settings.slotNumber > 1)? this.toggleSubmitBtn(true) : this.toggleSubmitBtn(false);

      if (this._settings.selectedSlot && this._settings.selectedDate) {
        this.updateSlots(null, this.selectedDate);
      }
    },

    setupCalendar: function() {
      this.Calendar = new moj.Modules.Slotpicker.Calendar(this.$el, this._settings);
      this.Calendar.init();
      this.Calendar.$el.on('updateSlotsList', $.proxy(this.updateSlots, this));
    },

    updateSlots: function(e, date) {
      this._settings.selectedDate = date;
      this.Slots = new moj.Modules.Slotpicker.Slots(this.$el, date, this._settings);
      this.Slots.init();
      this.Slots.$el.on('updateSelectedSlot', $.proxy(this.updateSelectedSlot, this));
      this.Slots.$el.on('toggleSubmit', $.proxy(this.toggleSubmitBtn, this));
    },

    updateSelectedSlot: function(e, slot) {
      this._settings.selectedSlot = slot;
      this.updateSlotSource(slot);
      this.toggleSubmitBtn(false);
    },

    updateSlotSource: function(slot) {
      moj.Modules.Slotpicker.SlotSource.setValue(slot);
    },

    toggleSubmitBtn: function(attr) {
      this.$submitBtn.attr('disabled', attr);
    }

  }

  moj.Modules.Slotpicker.Datepicker = Datepicker;

}());
