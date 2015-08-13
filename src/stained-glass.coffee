class StainedGlass
  constructor: (@img, @options) ->
    {@width, @height} = @img
    @options = {} unless @options?
    @mapImageColors()
    @generateDistribution()

  polygon: (d) -> "M#{d.join 'L'}Z"

  generateDistribution: ->
    @polygonNumber = @options.polygons or 100
    lineHeight = (@width - 1) / Math.sqrt @polygonNumber
    columnHeight = (@height - 1) / Math.sqrt @polygonNumber

    @options.deviation = 0.2 unless @options?.deviation?

    @vertices = d3.range @polygonNumber
      .map (d, i) =>
        ix = Math.floor i % (@width / columnHeight)
        iy = Math.floor i / @width * columnHeight

        centerX = ix * columnHeight + columnHeight / 2
        centerY = iy * lineHeight + lineHeight / 2

        x = d3.random.normal(centerX, columnHeight * @options.deviation)()
        y = d3.random.normal(centerY, lineHeight * @options.deviation)()

        @ensureInBounds x, y

    if @options.triangles
      @vertices = @vertices.concat @calculateSidePoints()
      @geom = d3.geom.delaunay

    else
      @geom = d3.geom.voronoi()
      .clipExtent [
          [0, 0]
          [@width, @height]
        ]

    # Replace the image by the svg element
    @svg = d3.select @img.parentNode
    .insert 'svg', 'img'
    .attr 'height', @height
    .attr 'width', @width
    .style
      display: 'inline-block'
      # height: "#{@height}px"
      # width: "#{@width}px"
    .classed 'stained-glass', true

    d3.select @img
    .style
      display: 'none'

    # Restore original classes
    @svg.classed c, true for c in @img.classList

    @pathGroup = @svg.append 'g'

    @updateDistribution()

  updateDistribution: ->
    path = @pathGroup.selectAll 'path'
    .data @geom(@vertices), @polygon

    path.exit()
    .remove()

    path.enter()
    .append 'path'
    .attr 'd', @polygon
    .style 'stroke-width', @options.strokeWidth or 1.51

    path.order()

    @updateColors()

  updateColors: ->
    deviationner = d3.random.normal 0, 10

    @options.animationDuration = 2000 unless @options.animationDuration

    updateTileColor = (tile, instant, deviations) =>
      tileSelection = d3.select tile

      tileSelection
      .each (d) =>
        unless d.point
          # Calculate the center of the triangle
          d.point = [
            (d[0][0] + d[1][0] + d[2][0]) / 3
            (d[0][1] + d[1][1] + d[2][1]) / 3
          ]

        x = Math.round d.point[0] + deviations[0]
        y = Math.round d.point[1] + deviations[1]
        colors = @getImageColors x, y
        d.color = "rgb(#{colors[0]},#{colors[1]},#{colors[2]})"

      animationDuration = if instant then 0 else @options.animationDuration

      tileAnimation = tileSelection
      .transition()
      .ease 'linear'
      .duration animationDuration
      .attr 'fill', (d) -> d.color
      .style 'stroke', (d) =>
        return d.color unless @options.stroke
        @options.stroke
      .style 'stroke-width', @options.strokeWidth or 1.51

      if @options.animated and not @options.followCursor
        tileAnimation
        .each 'end', ->
          updateTileColor this, false, [deviationner(), deviationner()]

    @pathGroup.selectAll 'path'
    .each -> updateTileColor this, true, [0, 0]

    if @options.followCursor
      self = @
      xCorrection = self.width / self.height / self.polygonNumber * 10
      yCorrection = self.height / self.width / self.polygonNumber * 10

      @pathGroup
      .on 'mousemove', (e) ->
        x = d3.mouse(this)[0]
        y = d3.mouse(this)[1]
        self.pathGroup.selectAll 'path'
        .each (d) -> updateTileColor this, false, [
          (d.point[0] - x) * xCorrection
          (d.point[1] - y) * yCorrection
        ]

  mapImageColors: ->
    @canvas = document.createElement 'canvas'

    @canvas.width = @width
    @canvas.height = @height

    @canvas.getContext '2d'
    .drawImage @img, 0, 0, @width, @height

  getImageColors: (x, y) ->
    [x, y] = @ensureInBounds x, y

    @canvas.getContext '2d'
    .getImageData x, y, 1, 1
    .data

  # Ensure bound are not crossed
  ensureInBounds: (x, y) ->
    x = d3.max [0, x]
    y = d3.max [0, y]
    x = d3.min [x, @width - 1]
    y = d3.min [y, @height - 1]
    [x, y]

  # returns coordinates of points to add on the sides
  # for to the triangles distribution
  calculateSidePoints: ->
    horizontalSidePointsNumber = Math.sqrt(@polygonNumber) * @width / @height
    verticalSidePointsNumber = Math.sqrt(@polygonNumber) * @height / @width

    sidePoints = []
    for x in [0..horizontalSidePointsNumber]
      xPoint = x * @width / horizontalSidePointsNumber
      sidePoints.push [xPoint, 0]
      sidePoints.push [xPoint, @height - 1]
    for y in [0..verticalSidePointsNumber]
      yPoint = y * @height / verticalSidePointsNumber
      sidePoints.push [0, yPoint]
      sidePoints.push [@width - 1, yPoint]

    sidePoints.push [@width - 1, @height - 1]

    sidePoints

window.StainedGlass = StainedGlass
