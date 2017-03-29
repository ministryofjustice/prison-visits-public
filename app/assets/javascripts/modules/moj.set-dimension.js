(function() {
  'use strict';

  moj.Modules.SetDimension = {
    el: '.js-SetDimension',

    init: function() {
      this.cacheEls();
      this.bindEvents();
    },

    bindEvents: function() {
      moj.Events.on('render', $.proxy(this.render, this));
    },

    cacheEls: function() {
      this.$el = $(this.el);
    },

    render: function() {
      if (this.$el.data('dimensionvalue')) {
        moj.Modules.Analytics.setDimension(this.$el.data('dimensionvalue'));
      }
    }
  };
}());