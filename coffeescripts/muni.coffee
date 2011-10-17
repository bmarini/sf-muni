Muni = Sammy ->
  
  @use Sammy.Muni
  @use Sammy.Template
  @use Sammy.Mustache
  
  @before ->
    console.log '>> route', this.path
  
  @get '#/routes', ( app ) ->
    @muni command : 'routeList', ( @response ) -> @partial 'templates/routes.mustache'
  
  @get '#/routes/:route', ( app ) ->
    @muni command : 'routeConfig', r : app.params.route, ( @response ) -> @partial 'templates/route.mustache'
  
  @get '#/stops/:stop', ( app ) ->
    @muni command : 'predictions', stopId : app.params.stop, ( @response ) -> @partial 'templates/stop.mustache'
    
  @get '#/', ( app ) ->
    @redirect '#/routes'

$ -> Muni.run '#/'
