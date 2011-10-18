Sammy ?= { }

Sammy.Muni = ( app ) ->
  
  @helper 'domain', ( command, data ) ->
    switch command
      when 'routeConfig'
        for direction in data.route.direction
          for stop in direction.stop
            $.extend stop, s for s in data.route.stop when s.tag is stop.tag
            $.extend stop, route : @params.route
    data
  
  @helper 'muni', ( options, success ) ->
    $.ajax
      data       : $.extend( options, a : 'sf-muni' ),
      url        : 'http://webservices.nextbus.com/service/publicXMLFeed'
      type       : 'GET'
      dataType   : 'xml'
      context    : this
      dataFilter : ( data ) => @domain options.command, $.xml2json data
      success    : ( response ) ->
        console.log 'success!', response
        success.call this, response
