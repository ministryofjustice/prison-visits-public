(function() {
  'use strict';

  moj.Modules.Slotpicker = moj.Modules.Slotpicker || {}

  var Slotpicker = {
    el: '.js-calendar',

    init: function() {
      if ($(this.el) && $(this.el).length > 0) {
        moj.Events.on('render', $.proxy(this.setup, this));
      }
    },

    setup: function() {
      this.$el = $(this.el);
      moj.Modules.Slotpicker.Helpers.init();
      var datepicker = new moj.Modules.Slotpicker.Datepicker(this.$el, this.$el.data());
      datepicker.init();
    }

  };

  $.extend(moj.Modules.Slotpicker, Slotpicker)

}());
