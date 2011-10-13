(function() {
  if (typeof Sammy === "undefined" || Sammy === null) {
    Sammy = {};
  }
  Sammy.Muni = function(app) {
    return this.helper('muni', function(options) {
      return $.ajax({
        data: {
          command: options.command,
          a: 'sf-muni'
        },
        url: 'http://webservices.nextbus.com/service/publicXMLFeed',
        type: 'GET',
        dataType: 'xml',
        dataFilter: function(data) {
          return $.xml2json(data);
        },
        success: function(response) {
          return console.log('success!', response);
        }
      });
    });
  };
}).call(this);
