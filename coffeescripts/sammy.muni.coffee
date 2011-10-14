Sammy ?= { }

Sammy.Muni = ( app ) ->
  
  @helper 'muni', ( options, success ) ->    
    $.ajax
      data       : $.extend( options, a : 'sf-muni' ),
      url        : 'http://webservices.nextbus.com/service/publicXMLFeed'
      type       : 'GET'
      dataType   : 'xml'
      context    : this
      dataFilter : ( data ) -> $.xml2json data
      success    : ( response ) ->
        console.log 'success!', response
        success.call this, response
