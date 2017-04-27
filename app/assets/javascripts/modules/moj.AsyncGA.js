/*global ga */
(function() {
  'use strict';

  moj.Modules.AsyncGA = {
    el: '.js-AsyncGA',
    init: function() {

      var gaTrackingId = $(this.el).eq(0).data('ga-tracking-id');
      var hitTypePage = $(this.el).eq(0).data('hit-type-page');

      window.ga = window.ga || function() {
        (ga.q = ga.q || []).push(arguments)
      };
      ga.l = +new Date;
      window.ga('create', gaTrackingId, 'service.gov.uk');

      if (hitTypePage) {
        window.ga('send', 'pageview', location.pathname + '#' + hitTypePage);
      } else {
        window.ga('send', 'pageview');
      }
    }
  };

}());