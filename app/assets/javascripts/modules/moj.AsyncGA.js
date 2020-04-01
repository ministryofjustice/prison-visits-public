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
      var self = this;
      window['ga-disable-UA-14565299-1'] = true;

      document.getElementById("accept-cookies").onclick = function() {
        self.hideCookieBanner();
        document.cookie =
          'accepted_cookies=true; expires=' +
          self.cookieOneYearExpiration() +
          ';';
        window['ga-disable-UA-14565299-1'] = false;

        self.trackPageView();
      };
      document.getElementById('reject-cookies').onclick = function() {
        document.cookie =
          'accepted_cookies=false; expires=' +
          self.cookieOneYearExpiration() +
          ';';
          window['ga-disable-UA-14565299-1'] = true;
        self.hideCookieBanner();
      };
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

      // Configure profiles and make interface public
      // for custom dimensions, virtual pageviews and events
      if (document.cookie.indexOf('accepted_cookies=true') > -1) {
        this.hideCookieBanner();
        window['ga-disable-UA-14565299-1'] = false;
        this.trackPageView();
      }
      if (document.cookie.indexOf('accepted_cookies=false') > -1) {
        this.hideCookieBanner();
        window['ga-disable-UA-14565299-1'] = true;
      }

      this.trackPageView();
    },

    trackPageView: function() {
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
      }
    },
    hideCookieBanner: function() {
      document.getElementById('cookie-message').style.display = 'none';
    },
    removeCookie: function(name) {
      document.cookie = name + '=; Max-Age=0';
    },
    cookieOneYearExpiration: function() {
      var date = new Date();
      date.setTime(+date + 365 * 86400000);
      return date.toGMTString();
    }
  };
})();
