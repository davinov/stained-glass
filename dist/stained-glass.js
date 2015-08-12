(function() {
  var StainedGlass;

  StainedGlass = (function() {
    function StainedGlass(img, options) {
      var ref;
      this.img = img;
      this.options = options;
      ref = this.img, this.width = ref.width, this.height = ref.height;
      if (this.options == null) {
        this.options = {};
      }
      this.mapImageColors();
      this.generateDistribution();
    }

    StainedGlass.prototype.polygon = function(d) {
      return "M" + (d.join('L')) + "Z";
    };

    StainedGlass.prototype.generateDistribution = function() {
      var c, columnHeight, j, len, lineHeight, ref, ref1;
      this.polygonNumber = this.options.polygons || 100;
      lineHeight = (this.width - 1) / Math.sqrt(this.polygonNumber);
      columnHeight = (this.height - 1) / Math.sqrt(this.polygonNumber);
      if (((ref = this.options) != null ? ref.deviation : void 0) == null) {
        this.options.deviation = 0.2;
      }
      this.vertices = d3.range(this.polygonNumber).map((function(_this) {
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
      if (this.options.triangles) {
        this.vertices = this.vertices.concat(this.calculateSidePoints());
        this.geom = d3.geom.delaunay;
      } else {
        this.geom = d3.geom.voronoi().clipExtent([[0, 0], [this.width, this.height]]);
      }
      this.svg = d3.select(this.img.parentNode).insert('svg').attr('height', this.height).attr('width', this.width).style({
        display: 'inline-block'
      }).classed('stained-glass', true);
      d3.select(this.img).style({
        display: 'none'
      });
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
      path = this.pathGroup.selectAll('path').data(this.geom(this.vertices), this.polygon);
      path.exit().remove();
      path.enter().append('path').attr('d', this.polygon).style('stroke-width', this.options.strokeWidth || 1.51);
      path.order();
      return this.updateColors();
    };

    StainedGlass.prototype.updateColors = function() {
      var deviationner, updateTileColor;
      deviationner = d3.random.normal(0, 10);
      updateTileColor = (function(_this) {
        return function(tile, instant, deviations) {
          var tileAnimation, tileSelection;
          tileSelection = d3.select(tile);
          tileSelection.each(function(d) {
            var colors, x, y;
            if (!d.point) {
              d.point = [(d[0][0] + d[1][0] + d[2][0]) / 3, (d[0][1] + d[1][1] + d[2][1]) / 3];
            }
            x = Math.round(d.point[0] + deviations[0]);
            y = Math.round(d.point[1] + deviations[1]);
            colors = _this.getImageColors(x, y);
            return d.color = "rgb(" + colors[0] + "," + colors[1] + "," + colors[2] + ")";
          });
          tileAnimation = tileSelection.transition().ease('linear').duration(instant ? 0 : 2000).attr('fill', function(d) {
            return d.color;
          }).style('stroke', function(d) {
            if (!_this.options.stroke) {
              return d.color;
            }
            return _this.options.stroke;
          }).style('stroke-width', _this.options.strokeWidth || 1.51);
          if (_this.options.animated) {
            return tileAnimation.each('end', function() {
              return updateTileColor(this, false, [deviationner(), deviationner()]);
            });
          }
        };
      })(this);
      return this.pathGroup.selectAll('path').each(function() {
        return updateTileColor(this, true, [0, 0]);
      });
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

    StainedGlass.prototype.calculateSidePoints = function() {
      var horizontalSidePointsNumber, j, k, ref, ref1, sidePoints, verticalSidePointsNumber, x, xPoint, y, yPoint;
      horizontalSidePointsNumber = Math.sqrt(this.polygonNumber) * this.width / this.height;
      verticalSidePointsNumber = Math.sqrt(this.polygonNumber) * this.height / this.width;
      sidePoints = [];
      for (x = j = 0, ref = horizontalSidePointsNumber; 0 <= ref ? j <= ref : j >= ref; x = 0 <= ref ? ++j : --j) {
        xPoint = x * this.width / horizontalSidePointsNumber;
        sidePoints.push([xPoint, 0]);
        sidePoints.push([xPoint, this.height - 1]);
      }
      for (y = k = 0, ref1 = verticalSidePointsNumber; 0 <= ref1 ? k <= ref1 : k >= ref1; y = 0 <= ref1 ? ++k : --k) {
        yPoint = y * this.height / verticalSidePointsNumber;
        sidePoints.push([0, yPoint]);
        sidePoints.push([this.width - 1, yPoint]);
      }
      sidePoints.push([this.width - 1, this.height - 1]);
      return sidePoints;
    };

    return StainedGlass;

  })();

  window.StainedGlass = StainedGlass;

}).call(this);
