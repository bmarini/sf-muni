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
    this.get('#/routes/:route', function(app) {
      return this.muni({
        command: 'routeConfig',
        r: app.params.route
      }, function(response) {
        this.response = response;
        return this.partial('templates/route.mustache');
      });
    });
    this.get('#/stops/:stop', function(app) {
      return this.muni({
        command: 'predictions',
        stopId: app.params.stop
      }, function(response) {
        this.response = response;
        return this.partial('templates/stop.mustache');
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
