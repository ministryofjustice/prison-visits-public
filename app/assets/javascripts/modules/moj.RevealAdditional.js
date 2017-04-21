(function() {
  'use strict';

  moj.Modules.RevealAdditional = {
    el: '.js-RevealAdditional',

    init: function() {
      this.cacheEls();
      this.bindEvents();
    },

    bindEvents: function() {
      var self = this;
      this.$select.on('change', function() {
        self.actuate(this);
      });
      this.$addButton.on('click', function() {
        self.addVisitor();
      });
      this.$removeButton.on('click', function() {
        self.removeVisitor();
      });
      moj.Events.on('render', $.proxy(this.render, this));
    },

    cacheEls: function() {
      this.$select = $(this.el).find('.js-RevealAdditionalSelect');
      this.$addButton = $('.js-RevealAdditionalButton');
      this.$removeButton = $('.js-HideAdditionalButton');
    },

    render: function() {
      var self = this;
      this.$select.each(function(i, el) {
        self.actuate(el);
      });
    },

    actuate: function(el) {
      var $el = $(el),
        targetClass = $el.data('targetEls'),
        $numToShow = parseInt($el.val(), 10),
        maxVisitors = $el.data('max-visitors');

      $(targetClass).each(function(i, el) {
        if (i < $numToShow) {
          $(el).show();
        } else {
          $(el).hide();
          $(el).find('input').val('');
        }
        $(el).removeClass('additional-visitor--last');
      });

      $(targetClass + ':visible').last().addClass('additional-visitor--last');

      if (maxVisitors == $numToShow + 1) {
        this.$addButton.hide();
      } else {
        this.$addButton.show();
      }
    },

    addVisitor: function() {
      var val = parseInt(this.$select.val(), 10);
      this.$select.val(val + 1).trigger('change');
    },

    removeVisitor: function() {
      var val = parseInt(this.$select.val(), 10);
      this.$select.val(val - 1).trigger('change');
    }
  };
}());