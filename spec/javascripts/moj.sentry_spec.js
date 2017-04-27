describe('Modules.Sentry', function() {

  describe('...Methods', function() {
    describe('...init', function() {

      it('should configure Raven', function() {
        expect(Raven.isSetup()).toBe(true);
      });
    });

  });
});
