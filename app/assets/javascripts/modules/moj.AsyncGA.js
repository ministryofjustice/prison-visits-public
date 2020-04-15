/*global ga */
(function() {
  "use strict";

  moj.Modules.AsyncGA = {
    el: ".js-AsyncGA",
    init: function() {
      if ($(this.el).length > 0) {
        var gaTrackingId = $(this.el).data("ga-tracking-id");
        this.render(gaTrackingId);
      }
    },

    render: function(gaTrackingId) {
      var self = this;
      window["ga-disable-UA-14565299-1"] = true;
      if (window.location.href.includes("cookies")) {
        document.getElementById("save_cookie_preference").onclick = function() {
          if (document.getElementById("accept_cookies-yes").checked == true) {
            self.acceptCookies();
          } else {
            self.rejectCookies();
          }
        };
      }
      document.getElementById("accept-cookies").onclick = function() {
        self.acceptCookies();
      };
      document.getElementById("reject-cookies").onclick = function() {
        self.rejectCookies();
      };
      var cookieDomain =
        document.domain === "www.gov.uk" ? ".www.gov.uk" : document.domain;

      (function(i, s, o, g, r, a, m) {
        i["GoogleAnalyticsObject"] = r;
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
        "script",
        "https://www.google-analytics.com/analytics.js",
        "ga"
      );

      ga("create", gaTrackingId, cookieDomain);

      // Configure profiles and make interface public
      // for custom dimensions, virtual pageviews and events
      if (document.cookie.indexOf("accepted_cookies=true") > -1) {
        this.hideCookieBanner();
        window["ga-disable-UA-14565299-1"] = false;
        this.trackPageView();
      }
      if (document.cookie.indexOf("accepted_cookies=false") > -1) {
        this.hideCookieBanner();
        window["ga-disable-UA-14565299-1"] = true;
      }
    },

    trackPageView: function() {
      window["ga-disable-UA-14565299-1"] = false;

      this.hitTypePage = $(this.el)
        .eq(0)
        .data("hit-type-page");
      this.pageView = $(this.el)
        .eq(0)
        .data("page-view");

      if (this.hitTypePage) {
        ga("send", "pageview", this.hitTypePage);
      } else if (this.pageView) {
        ga("send", "pageview", this.pageView);
      } else {
        ga("send", "pageview");
      }
    },
    hideCookieBanner: function() {
      document.getElementById("cookie-message").style.display = "none";
    },
    cookieOneYearExpiration: function() {
      var date = new Date();
      date.setFullYear(date.getFullYear() + 1);
      return date.toGMTString();
    },
    acceptCookies: function(){
      this.hideCookieBanner();
      document.cookie = "accepted_cookies=true; expires=" + this.cookieOneYearExpiration() + ";";
      this.trackPageView();
    },
    rejectCookies: function(){
      window["ga-disable-UA-14565299-1"] = true;
      this.hideCookieBanner();
      document.cookie = "accepted_cookies=false; expires=" + this.cookieOneYearExpiration() + ";";
    }
  };
})();
