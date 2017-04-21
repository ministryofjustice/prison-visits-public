describe('Modules.RevealAdditional', function() {

  beforeEach(function() {
    loadFixtures('visitors.html');
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


      it('should', function() {
        var select = $('.js-RevealAdditionalSelect');
        expect(select.val()).toBe('0');
      });

    });

  });
});