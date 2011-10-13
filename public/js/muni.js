(function() {
  var Muni;
  Muni = Sammy(function() {
    return this.use(Sammy.Muni);
  });
  Muni.run('#/');
}).call(this);
