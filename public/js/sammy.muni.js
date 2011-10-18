(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  if (typeof Sammy === "undefined" || Sammy === null) {
    Sammy = {};
  }
  Sammy.Muni = function(app) {
    this.helper('domain', function(command, data) {
      var direction, s, stop, _i, _j, _k, _len, _len2, _len3, _ref, _ref2, _ref3;
      switch (command) {
        case 'routeConfig':
          _ref = data.route.direction;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            direction = _ref[_i];
            _ref2 = direction.stop;
            for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
              stop = _ref2[_j];
              _ref3 = data.route.stop;
              for (_k = 0, _len3 = _ref3.length; _k < _len3; _k++) {
                s = _ref3[_k];
                if (s.tag === stop.tag) {
                  $.extend(stop, s);
                }
              }
              $.extend(stop, {
                route: this.params.route
              });
            }
          }
      }
      return data;
    });
    return this.helper('muni', function(options, success) {
      return $.ajax({
        data: $.extend(options, {
          a: 'sf-muni'
        }),
        url: 'http://webservices.nextbus.com/service/publicXMLFeed',
        type: 'GET',
        dataType: 'xml',
        context: this,
        dataFilter: __bind(function(data) {
          return this.domain(options.command, $.xml2json(data));
        }, this),
        success: function(response) {
          console.log('success!', response);
          return success.call(this, response);
        }
      });
    });
  };
}).call(this);
