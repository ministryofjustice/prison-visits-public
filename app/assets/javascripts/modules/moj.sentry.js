(function() {
  'use strict';

  moj.Modules.Sentry = {
    el: '.js-Sentry',
    init: function() {
      this.raven = Raven;
      this.sentry_js_dsn = $(this.el).data('sentry-js-dsn');
      this.raven.config(this.sentry_js_dsn).install();
      var sentry_module = this;

      // Capture any uncaught errors
      window.onerror = function(error) {
        sentry_module.raven.captureException(error);
      }
    }
  }
}());
