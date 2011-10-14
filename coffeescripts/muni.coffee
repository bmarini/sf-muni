Muni = Sammy ->
  
  @use Sammy.Muni
  @use Sammy.Template
  @use Sammy.Mustache
  
  @before ->
    console.log '>> route', this.path
  
  @get '#/routes', ( app ) ->
    @muni command : 'routeList', ( @response ) -> @partial 'templates/routes.mustache'
  
  @get '#/routes/:tag', ( app ) ->
    @muni command : 'routeConfig', r : app.params.tag, ( @response ) -> @partial 'templates/route.mustache'
      
  @get '#/', ( app ) ->
    @redirect '#/routes'

$ -> Muni.run '#/'
