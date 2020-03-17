/*global ga */
(function() {
  'use strict';

  moj.Modules.AsyncGA = {
    el: '.js-AsyncGA',
    init: function() {
      if ($(this.el).length > 0) {
        this.render();
      }
    },

    render: function() {
      // Use document.domain in dev, preview and staging so that tracking works
      // Otherwise explicitly set the domain as www.gov.uk (and not gov.uk).
      var cookieDomain =
        document.domain === 'www.gov.uk' ? '.www.gov.uk' : document.domain;
      var gaTrackingId = $(this.el).data('ga-tracking-id');

      (function(i, s, o, g, r, a, m) {
        i['GoogleAnalyticsObject'] = r;
        (i[r] =
          i[r] ||
          function() {
            (i[r].q = i[r].q || []).push(arguments);
          }),
          (i[r].l = 1 * new Date());
        (a = s.createElement(o)), (m = s.getElementsByTagName(o)[0]);
        a.async = 1;
        a.src = g;
        m.parentNode.insertBefore(a, m);
      })(
        window,
        document,
        'script',
        'https://www.google-analytics.com/analytics.js',
        'ga'
      );

      ga('create', gaTrackingId, cookieDomain);
      ga('create', 'UA-145652997-1', cookieDomain, 'govuk_shared', {
        allowLinker: true
      });
      ga('govuk_shared.require', 'linker');
      ga('govuk_shared.linker:autoLink', ['www.gov.uk']);
      // Configure profiles and make interface public
      // for custom dimensions, virtual pageviews and events

      this.hitTypePage = $(this.el)
        .eq(0)
        .data('hit-type-page');
      this.pageView = $(this.el)
        .eq(0)
        .data('page-view');

      if (this.hitTypePage) {
        ga('send', 'pageview', this.hitTypePage);
      } else if (this.pageView) {
        ga('send', 'pageview', this.pageView);
      } else {
        ga('send', 'pageview');
        ga('govuk_shared.send', 'pageview', { anonymizeIp: true });
      }
    }
  };
})();
