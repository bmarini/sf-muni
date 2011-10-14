(function() {
  var Muni;
  Muni = Sammy(function() {
    this.use(Sammy.Muni);
    this.use(Sammy.Template);
    this.use(Sammy.Mustache);
    this.before(function() {
      return console.log('>> route', this.path);
    });
    this.get('#/routes', function(app) {
      return this.muni({
        command: 'routeList'
      }, function(response) {
        this.response = response;
        return this.partial('templates/routes.mustache');
      });
    });
    this.get('#/routes/:tag', function(app) {
      return this.muni({
        command: 'routeConfig',
        r: app.params.tag
      }, function(response) {
        this.response = response;
        return this.partial('templates/route.mustache');
      });
    });
    return this.get('#/', function(app) {
      return this.redirect('#/routes');
    });
  });
  $(function() {
    return Muni.run('#/');
  });
}).call(this);
