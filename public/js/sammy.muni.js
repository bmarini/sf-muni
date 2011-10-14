(function() {
  if (typeof Sammy === "undefined" || Sammy === null) {
    Sammy = {};
  }
  Sammy.Muni = function(app) {
    return this.helper('muni', function(options, success) {
      return $.ajax({
        data: $.extend(options, {
          a: 'sf-muni'
        }),
        url: 'http://webservices.nextbus.com/service/publicXMLFeed',
        type: 'GET',
        dataType: 'xml',
        context: this,
        dataFilter: function(data) {
          return $.xml2json(data);
        },
        success: function(response) {
          console.log('success!', response);
          return success.call(this, response);
        }
      });
    });
  };
}).call(this);
