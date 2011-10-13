Sammy ?= { }

Sammy.Muni = ( app ) ->
  
  @helper 'muni', ( options ) ->    
    $.ajax
      data       :
        command  : options.command
        a        : 'sf-muni'
      url        : 'http://webservices.nextbus.com/service/publicXMLFeed'
      type       : 'GET'
      dataType   : 'xml'
      dataFilter : ( data ) -> $.xml2json data
      success    : ( response ) ->
        console.log 'success!', response
