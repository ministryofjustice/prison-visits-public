(function() {
  'use strict';

  moj.Modules.Sentry = {
    el: '.js-Sentry',
    init: function() {
      this.raven = Raven;
      this.sentry_js_dsn = $(this.el).data('sentry-js-dsn');
      this.raven.config(this.sentry_js_dsn).install();

      // Capture any uncaught errors
      // window.onerror = $.proxy(this.handleException, this);
    },
    handleException: function(error) {
      this.raven.captureException(error);
    }
  }
}());
