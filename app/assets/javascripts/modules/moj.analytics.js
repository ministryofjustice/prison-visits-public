(function() {
  'use strict';

  moj.Modules.Analytics = {
    send: function(gaParams) {
      ga('send', 'event', gaParams.category, gaParams.action, gaParams.label);
    },
    setDimension: function(dimensionValue) {
      ga('set', dimensionValue[0].name, String(dimensionValue[0].value));
    }
  };
}());