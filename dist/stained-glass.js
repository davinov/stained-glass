(function() {
  var StainedGlass;

  StainedGlass = (function() {
    function StainedGlass(img, options) {
      var ref;
      this.img = img;
      this.options = options;
      ref = this.img, this.width = ref.width, this.height = ref.height;
      this.mapImageColors();
      this.generateDistribution();
    }

    StainedGlass.prototype.polygon = function(d) {
      return "M" + (d.join('L')) + "Z";
    };

    StainedGlass.prototype.generateDistribution = function() {
      var c, columnHeight, j, len, lineHeight, polygonNumber, ref, ref1;
      polygonNumber = this.options.polygons || 100;
      lineHeight = (this.width - 1) / Math.sqrt(polygonNumber);
      columnHeight = (this.height - 1) / Math.sqrt(polygonNumber);
      if (((ref = this.options) != null ? ref.deviation : void 0) == null) {
        this.options.deviation = 0.2;
      }
      this.vertices = d3.range(this.options.polygons || 100).map((function(_this) {
        return function(d, i) {
          var centerX, centerY, ix, iy, x, y;
          ix = Math.floor(i % (_this.width / columnHeight));
          iy = Math.floor(i / _this.width * columnHeight);
          centerX = ix * columnHeight + columnHeight / 2;
          centerY = iy * lineHeight + lineHeight / 2;
          x = d3.random.normal(centerX, columnHeight * _this.options.deviation)();
          y = d3.random.normal(centerY, lineHeight * _this.options.deviation)();
          return _this.ensureInBounds(x, y);
        };
      })(this));
      this.voronoi = d3.geom.voronoi().clipExtent([[0, 0], [this.width, this.height]]);
      d3.select(this.img).style({
        display: 'none'
      });
      this.svg = d3.select(this.img.parentNode).append('svg').attr('width', this.width).attr('height', this.height).classed('stained-glass', true);
      ref1 = this.img.classList;
      for (j = 0, len = ref1.length; j < len; j++) {
        c = ref1[j];
        this.svg.classed(c, true);
      }
      this.pathGroup = this.svg.append('g');
      return this.updateDistribution();
    };

    StainedGlass.prototype.updateDistribution = function() {
      var path;
      path = this.pathGroup.selectAll('path').data(this.voronoi(this.vertices), this.polygon);
      path.exit().remove();
      path.enter().append('path').attr('d', this.polygon).style('stroke-width', this.options.strokeWidth || 1.51);
      path.order();
      return this.updateColors();
    };

    StainedGlass.prototype.updateColors = function() {
      return this.pathGroup.selectAll('path').each((function(_this) {
        return function(d) {
          var colors;
          colors = _this.getImageColors(Math.round(d.point[0]), Math.round(d.point[1]));
          return d.color = "rgb(" + colors[0] + "," + colors[1] + "," + colors[2] + ")";
        };
      })(this)).attr('fill', function(d) {
        return d.color;
      }).style('stroke', (function(_this) {
        return function(d) {
          if (!_this.options.stroke) {
            return d.color;
          }
          return _this.options.stroke;
        };
      })(this)).style('stroke-width', this.options.strokeWidth || 1.51);
    };

    StainedGlass.prototype.mapImageColors = function() {
      this.canvas = document.createElement('canvas');
      this.canvas.width = this.width;
      this.canvas.height = this.height;
      return this.canvas.getContext('2d').drawImage(this.img, 0, 0, this.width, this.height);
    };

    StainedGlass.prototype.getImageColors = function(x, y) {
      var ref;
      ref = this.ensureInBounds(x, y), x = ref[0], y = ref[1];
      return this.canvas.getContext('2d').getImageData(x, y, 1, 1).data;
    };

    StainedGlass.prototype.ensureInBounds = function(x, y) {
      x = d3.max([0, x]);
      y = d3.max([0, y]);
      x = d3.min([x, this.width - 1]);
      y = d3.min([y, this.height - 1]);
      return [x, y];
    };

    return StainedGlass;

  })();

  window.StainedGlass = StainedGlass;

}).call(this);
