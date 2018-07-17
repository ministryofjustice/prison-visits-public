/*global ga */
(function() {
  'use strict';

  moj.Modules.AsyncGA = {
    el: '.js-AsyncGA',
    init: function() {
      GOVUK.Analytics.load();
      if($(this.el).length>0){
        this.render();
      }
    },

    render: function() {
      // Use document.domain in dev, preview and staging so that tracking works
      // Otherwise explicitly set the domain as www.gov.uk (and not gov.uk).
      var cookieDomain = (document.domain === 'www.gov.uk') ? '.www.gov.uk' : document.domain;
      var gaTrackingId = $(this.el).data('ga-tracking-id');

      // Configure profiles and make interface public
      // for custom dimensions, virtual pageviews and events
      GOVUK.analytics = new GOVUK.Analytics({
        universalId: gaTrackingId,
        cookieDomain: cookieDomain
      });

      this.hitTypePage  = $(this.el).eq(0).data('hit-type-page');
      this.pageView = $(this.el).eq(0).data('page-view');

      if (this.hitTypePage) {
        GOVUK.analytics.trackPageview(this.hitTypePage);
      } else if (this.pageView) {
        GOVUK.analytics.trackPageview(this.pageView);
      } else {
        GOVUK.analytics.trackPageview();
      }
    }
  };

}());
