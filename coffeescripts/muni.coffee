@Muni = Sammy '#muni', ->
  
  @use Sammy.Muni
  @use Sammy.Template
  @use Sammy.Mustache
  @use Sammy.Storage
  
  @store 'cache', type : 'local'
  
  @helper 'favorite', ( route, stop ) ->
    @cache stop, route
  
  @helper 'favorites', ->
    { stop : key, route : @cache key } for key in @store( 'cache' ).keys( )
    
  @before ->
    console.log '>> route', this.path
  
  @get '#/routes', ( app ) ->
    @muni command : 'routeList', ( @response ) -> @partial 'templates/routes.mustache'
  
  @get '#/routes/:route', ( app ) ->
    @muni command : 'routeConfig', r : app.params.route, ( @response ) -> @partial 'templates/route.mustache'
  
  @get '#/routes/:route/:stop', ( app ) ->
    @muni command : 'predictions', r : app.params.route, s : app.params.stop, ( @response ) -> @partial 'templates/stop.mustache'
  
  @get '#/favorite', ( app ) ->
    @favorite stop.split( '|' )... for stop in $.makeArray app.params.stops
    @redirect '#/favorites'
  
  @get '#/favorites', ( app ) ->
    @partial 'templates/favorites.mustache'
    
  @get '#/', ( app ) ->
    @redirect '#/routes'

$ -> Muni.run '#/'
