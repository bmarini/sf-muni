@Muni = Sammy '#muni', ->
  
  @use Sammy.Muni
  @use Sammy.Template
  @use Sammy.Mustache
  @use Sammy.Storage
  
  @store 'storage'
  
  @helper 'favorites', -> @storage 'favorites'
  
  @before ->
    console.log '>> route', this.path
  
  @get '#/routes', ( app ) ->
    @muni command : 'routeList', ( @response ) -> @partial 'templates/routes.mustache'
  
  @get '#/routes/:route', ( app ) ->
    @muni command : 'routeConfig', r : app.params.route, ( @response ) -> @partial 'templates/route.mustache'
  
  @get '#/routes/:route/:stop', ( app ) ->
    @muni command : 'predictions', r : app.params.route, s : app.params.stop, ( @response ) -> @partial 'templates/stop.mustache'
  
  @get '#/favorites', ( app ) ->
    console.log @favorites()
    @partial 'templates/favorites.mustache'
    
  @get '#/', ( app ) ->
    @redirect '#/routes'

$ -> Muni.run '#/'
