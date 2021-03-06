// Generated by CoffeeScript 1.3.3
(function() {

  require(['jquery', 'd3', 'underscore'], function($, d3, _) {
    var addAxes, addAxesAnnotations, c, circleTweetCount, countries_g, explode, geoTweet, listUsers, removeAxes, scaleTweetCount, scaleTweetCountLog, scatterPlot, slide, stats, svg, users;
    c = {
      width: $(document).width() * 0.98,
      height: $(document).height() * 0.97,
      transitionLength: 2000
    };
    svg = d3.select('body').append('svg').attr('width', c.width).attr('height', c.height);
    countries_g = svg.append('svg:g').attr('class', 'countries');
    users = svg.selectAll('circle.user').data([], function(d) {
      return d.user_id;
    });
    users = null;
    stats = {};
    listUsers = function() {
      var columnSpacing, perColumn, spacing;
      perColumn = 20;
      spacing = c.height / perColumn;
      columnSpacing = c.width / 5;
      return users.append('text').text(function(d) {
        return d.screen_name;
      }).attr('y', function(d, i) {
        return (i % perColumn) * spacing;
      }).attr('x', function(d, i) {
        var colN;
        colN = Math.floor(i / perColumn);
        return colN * columnSpacing;
      });
    };
    circleTweetCount = function() {
      users.append('circle').transition().duration(c.transitionLength).attr('r', function(d) {
        return d.statuses_count;
      }).attr('cx', c.width / 2).attr('cy', c.height * 0.75);
      return users.select('text').transition().duration(c.transitionLength).text(function(d) {
        return d.screen_name;
      }).style('text-anchor', 'middle').attr('x', c.width / 2).attr('y', function(d) {
        return (c.height * 0.75) - d.statuses_count;
      }).attr('transform', function(d, i) {
        var cx, cy;
        d = ((i * 5) % 90) - 45;
        cx = c.width / 2;
        cy = c.height * 0.75;
        return "rotate(" + d + "," + cx + "," + cy + ")";
      });
    };
    scaleTweetCount = function() {
      var y, _y;
      _y = d3.scale.linear().domain(stats.statuses_count).range([0, c.height]);
      y = function(d, i) {
        return c.height - _y(d, i);
      };
      users.select('circle').transition().duration(c.transitionLength).attr('r', 5).attr('cy', function(d) {
        return y(d.statuses_count);
      });
      return users.select('text').transition().duration(c.transitionLength).attr('x', (c.width / 2) + 3).attr('y', function(d) {
        return y(d.statuses_count);
      }).style('text-anchor', 'start').attr('transform', function(d) {
        return "rotate(0)";
      });
    };
    scaleTweetCountLog = function() {
      var y, _y;
      _y = d3.scale.linear().domain([stats.statuses_count[0], stats.statuses_count[1] / 1000]).range([0, c.height]);
      y = function(d, i) {
        return c.height - _y(d, i);
      };
      users.select('circle').transition().duration(c.transitionLength).attr('r', 5).attr('cy', function(d) {
        return y(d.statuses_count);
      });
      return users.select('text').transition().duration(c.transitionLength).attr('y', function(d) {
        return y(d.statuses_count);
      });
    };
    addAxes = function() {
      var axis, x, y, _y;
      _y = d3.scale.linear().domain(stats.statuses_count).range([0, c.height]);
      y = function(d, i) {
        return c.height - _y(d, i);
      };
      x = d3.time.scale().domain(stats.signed_up).range([0, c.width]);
      axis = svg.append('svg:g').attr('class', 'axis');
      axis.append('text').text('Joined recently').style('text-anchor', 'end').attr('x', c.width - 20).attr('y', c.height / 2 - 10);
      axis.append('text').text('Joined ages ago').style('text-anchor', 'start').attr('x', 20).attr('y', c.height / 2 - 10);
      axis.append('text').text('Loads a tweets').style('text-anchor', 'end').attr('y', 20).attr('x', c.width / 2 - 10);
      axis.append('text').text('Nay tweets').style('text-anchor', 'end').attr('y', c.height - 20).attr('x', c.width / 2 - 10);
      axis.append('line').attr('y1', c.height / 2 + 0.5).attr('y2', c.height / 2 + 0.5).attr('x1', 0).attr('x2', c.width);
      return axis.append('line').attr('x1', c.width / 2 + 0.5).attr('x2', c.width / 2 + 0.5).attr('y1', 0).attr('y2', c.height);
    };
    addAxesAnnotations = function() {
      svg.select('g.axis').append('text').text('Too keen').attr('x', c.width * 0.75).attr('y', c.height * 0.25);
      svg.select('g.axis').append('text').text('Old Bores').attr('x', c.width * 0.25).attr('y', c.height * 0.25);
      svg.select('g.axis').append('text').text('Shy and retiring').attr('x', c.width * 0.25).attr('y', c.height * 0.75);
      return svg.select('g.axis').append('text').text('Learning the ropes').attr('x', c.width * 0.75).attr('y', c.height * 0.75);
    };
    removeAxes = function() {
      return svg.select('g.axis').remove();
    };
    scatterPlot = function() {
      var x, y, _y;
      addAxes();
      _y = d3.scale.linear().domain(stats.statuses_count).range([0, c.height]);
      y = function(d, i) {
        return c.height - _y(d, i);
      };
      x = d3.time.scale().domain(stats.signed_up).range([0, c.width]);
      users.select('circle').transition().duration(c.transitionLength).attr('cx', function(d) {
        return x(d.signed_up);
      }).attr('cy', function(d) {
        return y(d.statuses_count);
      });
      return users.select('text').transition().duration(c.transitionLength).attr('x', function(d) {
        return x(d.signed_up);
      }).attr('y', function(d) {
        return y(d.statuses_count);
      });
    };
    geoTweet = function() {
      var circle, clip, origin, path, projection,
        _this = this;
      origin = [-3.22, 55.95];
      projection = d3.geo.azimuthal().scale(10).origin(origin).mode('orthographic').translate([c.width / 2, c.height / 2]);
      path = d3.geo.path().projection(projection).pointRadius(3);
      circle = d3.geo.greatCircle().origin(projection.origin());
      clip = function(d) {
        return path(circle.clip(d));
      };
      return d3.json('world-countries.json', function(collection) {
        var countries, delta, ease, originalOrigin, originalScale, redraw, scaleTimeLength, sease, spin, spinTimeLength, spun, startSpin;
        redraw = function() {
          countries_g.selectAll('path').attr('d', clip);
          users.select('circle').attr('cx', function(d) {
            return projection(d.geocoords)[0];
          }).attr('cy', function(d) {
            return projection(d.geocoords)[1];
          });
          return users.select('text').attr('x', function(d) {
            return projection(d.geocoords)[0];
          }).attr('y', function(d) {
            return projection(d.geocoords)[1];
          }).attr('transform', function(d, i) {
            var angle, p;
            angle = (i * 5) % 360;
            p = projection(d.geocoords);
            if (angle > 180) {
              return "rotate(" + angle + "," + p[0] + "," + p[1] + ")";
            } else {
              return "rotate(" + angle + "," + p[0] + "," + p[1] + ")";
            }
          });
        };
        spun = 0;
        delta = 40;
        spinTimeLength = 6000;
        scaleTimeLength = 6000;
        originalOrigin = projection.origin();
        originalScale = projection.scale();
        ease = d3.ease('elastic');
        sease = d3.ease('cubic-in');
        spin = function(timestep) {
          var scale;
          spun = 360 * ease(timestep / spinTimeLength);
          scale = originalScale + 10000 * sease(timestep / scaleTimeLength);
          origin = [originalOrigin[0] + spun, originalOrigin[1]];
          projection.origin(origin);
          circle.origin(origin);
          projection.scale(scale);
          redraw();
          if (timestep >= spinTimeLength && timestep >= scaleTimeLength) {
            return true;
          } else {
            return false;
          }
        };
        startSpin = function() {
          return d3.timer(spin);
        };
        countries = countries_g.selectAll('path').data(collection.features).enter().append('svg:path').attr('d', clip);
        users.select('text').transition().duration(2000).attr('x', function(d) {
          return projection(d.geocoords)[0];
        }).attr('y', function(d) {
          return projection(d.geocoords)[1];
        }).attr('transform', function(d, i) {
          var angle, p;
          angle = (i * 5) % 360;
          p = projection(d.geocoords);
          return "rotate(" + angle + "," + p[0] + "," + p[1] + ")";
        }).style('font-size', '12px');
        return users.select('circle').transition().duration(2000).attr('r', 3).attr('cx', function(d) {
          return projection(d.geocoords)[0];
        }).attr('cy', function(d) {
          return projection(d.geocoords)[1];
        }).each('end', startSpin);
      });
    };
    slide = function(text) {
      return function() {
        slide = svg.append('svg:g').attr('class', 'slide');
        return slide.append('text').text(text).style('text-anchor', 'middle').attr('y', c.height / 2).attr('x', c.width + 500).transition().duration(c.transitionLength).attr('x', c.width / 2);
      };
    };
    explode = function() {
      svg.selectAll('text').transition().duration(c.transitionLength).attr('x', -500).remove();
      svg.selectAll('path').transition().duration(c.transitionLength).attr('transform', "translate(-50000,0)").remove();
      return svg.selectAll('circle').transition().duration(c.transitionLength).attr('cx', -500).remove();
    };
    return d3.json('locations.json', function(locations) {
      return d3.json('users.json', function(coll) {
        var currSlide, nextSlide, slides;
        coll = coll.map(function(u) {
          u.geocoords = locations[u.id];
          u.signed_up = new Date(Date.parse(u.created_at));
          return u;
        });
        coll = coll.filter(function(u) {
          return u.geocoords;
        });
        coll = coll.slice(0, 101);
        coll = _.sortBy(coll, function(u) {
          return u.statuses_count;
        });
        users = svg.selectAll('g.user').data(coll, function(d) {
          return d.user_id;
        });
        users.enter().append('svg:g').attr('class', 'user');
        stats.statuses_count = d3.extent(coll, function(d) {
          return d.statuses_count;
        });
        stats.signed_up = d3.extent(coll, function(d) {
          return d.signed_up;
        });
        currSlide = 0;
        slides = [];
        nextSlide = function() {
          slide = svg.selectAll('g.slide');
          if (slide[0].length > 0) {
            slide.select('text').transition().duration(500).attr('x', -500).remove();
            slides[currSlide]();
          } else {
            slides[currSlide]();
          }
          return currSlide++;
        };
        slides.push(slide("Hello"));
        slides.push(slide("Tweets"));
        slides.push(slide("How many?"));
        slides.push(listUsers);
        slides.push(circleTweetCount);
        slides.push(scaleTweetCount);
        slides.push(scatterPlot);
        slides.push(addAxesAnnotations);
        slides.push(removeAxes);
        slides.push(geoTweet);
        slides.push(explode);
        slides.push(slide("So like, wth?"));
        slides.push(slide("So like, wth?"));
        nextSlide();
        return svg.on('click', nextSlide);
      });
    });
  });

}).call(this);
