// Vendor assets
//= require modernizr-custom
//= require dest/respond.min
//= require raven-3.14.2.min.js

// GOVUK modules
//= require govuk_toolkit
//= require vendor/polyfills/bind

// MOJ elements
//= require moj
//= require src/moj.TimeoutPrompt

// Raven / Sentry
//= require modules/moj.sentry

// Candidates for re-usable components
//= require modules/moj.analytics
//= require modules/moj.autocomplete
//= require modules/moj.hijacks
//= require modules/moj.submit-once
//= require modules/moj.RevealAdditional
//= require modules/moj.booking-calendar
//= require modules/moj.AsyncGA

(function() {
  'use strict';
  if (!$('body').hasClass('js-enabled')) {
    $('body').addClass('js-enabled');
  }
  delete moj.Modules.devs;
  moj.Modules.Sentry.capture(function() {
    moj.init();
  }
}());
