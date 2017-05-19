(function() {
  'use strict';

  moj.Modules.Sentry = {
    el: '.js-Sentry',
    init: function() {
      this.raven = Raven;
      this.sentry_js_dsn = $(this.el).data('sentry-js-dsn');
      this.raven.config(this.sentry_js_dsn).install();
    },
    handleException: function(error) {
      this.raven.captureException(error);
    }
  }
}());
