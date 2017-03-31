// Timeout prompt for MOJ
// Dependencies: moj, jQuery
(function () {

  'use strict';

  window.moj = window.moj || { Modules: {} };

  var TimeoutPrompt = function($el, options) {
    this.init($el, options);
    return this;
  };

  TimeoutPrompt.prototype = {

    defaults: {
      timeoutMinutes: 17,
      respondMinutes: 3,
      exitPath: '/abandon',
      alert: '.TimeoutPrompt-alert'
    },

    timeout: null,
    respond: null,

    init: function ($el, options) {
      this.settings = $.extend({}, this.defaults, options);
      this.settings.timeoutDuration = this.convertToMinutes(this.settings.timeoutMinutes);
      this.settings.respondDuration = this.convertToMinutes(this.settings.respondMinutes);
      this.cacheEls($el);
      this.startTimeout();
    },

    convertToMinutes: function(num) {
      return num * 1000 * 60;
    },

    cacheEls: function($el) {
      this.$el = $el;
      this.$alert = this.alertPrompt();
    },

    alertPrompt: function() {
      var prompt = this.$el.find(this.settings.alert);
      var s = prompt.find('#timeoutTitle span').html(this.settings.respondMinutes);
      return prompt;
    },
    bindEvents: function() {
      this.$el.find('.TimeoutPrompt-extend').on('click', $.proxy(this.removeAlert, this));
    },

    startTimeout: function () {
      this.timeout = setTimeout(
        $.proxy(
          this.showAlert,
          this,
          this.settings.respondDuration
        ),
        this.settings.timeoutDuration
      );
    },

    showAlert: function (ms) {
      this.$alert.removeClass('visuallyhidden').focus();
      this.respond = setTimeout($.proxy(this.redirect, this), ms, this.settings.exitPath);
      this.bindEvents();
    },

    redirect: function (path) {
      window.location.href = path;
    },

    removeAlert: function () {
      this.$alert.addClass('visuallyhidden');
      clearTimeout(this.timeout);
      this.refreshSession();
    },

    refreshSession: function () {
      var self = this;
      $.ajax({
        url: $('#logo img').attr('src'),
        cache: false
      }).done(function () {
        self.startTimeout(self.settings.timeoutDuration);
        clearTimeout(self.respond);
      });
    }
  };

  moj.Modules._TimeoutPrompt = TimeoutPrompt;

  moj.Modules.TimeoutPrompt = {
    init: function() {
      return $('.TimeoutPrompt').each(function() {
        $(this).data('TimeoutPrompt', new TimeoutPrompt($(this), $(this).data()));
      });
    }
  };

}());
