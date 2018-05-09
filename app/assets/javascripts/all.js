// Vendor assets
//= require modernizr-custom
//= require dest/respond.min
//= require raven-3.24.2.min.js

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
//= require modules/moj.AsyncGA


//= require modules/slotpicker/_helpers
//= require modules/slotpicker/_source
//= require modules/slotpicker/_calendar
//= require modules/slotpicker/_slots
//= require modules/slotpicker/moj.datepicker
//= require modules/slotpicker/moj.slotpicker

(function() {
  'use strict';
  if (!$('body').hasClass('js-enabled')) {
    $('body').addClass('js-enabled');
  }
  delete moj.Modules.devs;
  moj.Modules.Sentry.capture(function() {
    moj.init();
  })
}());
