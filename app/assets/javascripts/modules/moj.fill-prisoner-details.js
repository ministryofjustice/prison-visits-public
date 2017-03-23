(function() {

  'use strict';

  moj.Modules.PrisonerDetails = {
    el: '.js-prisonerDetails',

    init: function() {
      var self = this;
      $(this.el).on('click', function(e) {
        self.fill($(this).data('prisoner')[0])
        if ($(this).data('visitor') == 1) {
          $('.form-date input').eq(0).val(25)
          $('.form-date input').eq(1).val(3)
          $('.form-date input').eq(2).val(1985)
        }
      });
    },

    fill: function(data) {
      var prop, form = $('form');

      for (var key in data) {
        form.find('#' + key).val(data[key])
      }

      var e = jQuery.Event('keydown');
      e.which = 13;
      $('#prisoner_step_prison_id').trigger(e);
      setTimeout(function() {
        $('.ui-autocomplete li a').trigger('click');
      }, 500);
    }
  };
}());