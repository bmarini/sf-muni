(function() {
  this.Muni = Sammy('#muni', function() {
    this.use(Sammy.Muni);
    this.use(Sammy.Template);
    this.use(Sammy.Mustache);
    this.use(Sammy.Storage);
    this.store('storage');
    this.helper('favorites', function() {
      return this.storage('favorites');
    });
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
    this.get('#/routes/:route/:stop', function(app) {
      return this.muni({
        command: 'predictions',
        r: app.params.route,
        s: app.params.stop
      }, function(response) {
        this.response = response;
        return this.partial('templates/stop.mustache');
      });
    });
    this.get('#/favorites', function(app) {
      console.log(this.favorites());
      return this.partial('templates/favorites.mustache');
    });
    return this.get('#/', function(app) {
      return this.redirect('#/routes');
    });
  });
  $(function() {
    return Muni.run('#/');
  });
}).call(this);
