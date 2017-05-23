(function() {
  'use strict';

  moj.Modules.Sentry = {
    el: '.js-Sentry',
    init: function() {
      this.raven = Raven;
      this.raven.config('https://sentry.service.dsd.io/59').install()
    }
  }
}());
