// Vendor assets
//= require jquery
//= require jquery_ujs
//= require jquery-ui-autocomplete
//= require modernizr-custom
//= require dest/respond.min

// GOVUK modules
//= require govuk_toolkit
//= require vendor/polyfills/bind
//= require govuk/selection-buttons

// MOJ elements
//= require moj
//= require src/moj.TimeoutPrompt

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
  var selectionButtons = new GOVUK.SelectionButtons("label input[type='radio'], label input[type='checkbox']");
  moj.init();
}());