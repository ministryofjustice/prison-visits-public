var select;
describe('Modules.RevealAdditional', function() {

  beforeEach(function() {
    loadFixtures('visitors.html');
    select = $('.js-RevealAdditionalSelect');
  });

  describe('...Methods', function() {
    describe('...init', function() {

      beforeEach(function() {
        spyOn(moj.Modules.RevealAdditional, 'cacheEls');
        spyOn(moj.Modules.RevealAdditional, 'bindEvents');

      });

      it('should call `this.cacheEls`', function() {
        moj.Modules.RevealAdditional.init();
        expect(moj.Modules.RevealAdditional.cacheEls).toHaveBeenCalled();
      });

      it('should call `this.bindEvents`', function() {
        moj.Modules.RevealAdditional.init();
        expect(moj.Modules.RevealAdditional.bindEvents).toHaveBeenCalled();
      });
    });

    describe('...after init', function() {

      beforeEach(function() {
        moj.Modules.RevealAdditional.init();
      });

      it('select should be 0 by default', function() {
        expect(select.val()).toBe('0');
      });

    });

    describe('Clicking Add another visitor', function() {

      beforeEach(function() {
        moj.Modules.RevealAdditional.init();
        $('.js-RevealAdditionalButton').click();
      });

      it('should increment the select list value', function() {
        expect(select.val()).toBe('1');
      });

      it('should show one Remove visitor button', function() {
        expect($('.additional-visitor--last').length).toBe(1);
      });

    });

    describe('Clicking Remove visitor', function() {

      beforeEach(function() {
        moj.Modules.RevealAdditional.init();
        $('.js-RevealAdditionalButton').click();
      });

      it('should decrement the select list value', function() {
        $('.js-HideAdditionalButton').last().click();
        expect(select.val()).toBe('0');
      });

    });

  });
});
