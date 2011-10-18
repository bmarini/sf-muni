(function() {
  this.Muni = Sammy('#muni', function() {
    this.use(Sammy.Muni);
    this.use(Sammy.Template);
    this.use(Sammy.Mustache);
    this.use(Sammy.Storage);
    this.store('cache', {
      type: 'local'
    });
    this.helper('favorite', function(route, stop) {
      return this.cache(stop, route);
    });
    this.helper('favorites', function() {
      var key, _i, _len, _ref, _results;
      _ref = this.store('cache').keys();
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        key = _ref[_i];
        _results.push({
          stop: key,
          route: this.cache(key)
        });
      }
      return _results;
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
    this.get('#/favorite', function(app) {
      var stop, _i, _len, _ref;
      _ref = $.makeArray(app.params.stops);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        stop = _ref[_i];
        this.favorite.apply(this, stop.split('|'));
      }
      return this.redirect('#/favorites');
    });
    this.get('#/favorites', function(app) {
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
