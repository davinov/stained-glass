class StainedGlass
  constructor: (@img, @options) ->
    {@width, @height} = @img
    @mapImageColors()
    @generateDistribution()

  polygon: (d) -> "M#{d.join 'L'}Z"

  generateDistribution: ->
    polygonNumber = @options.polygons or 100
    lineHeight = (@width - 1) / Math.sqrt polygonNumber
    columnHeight = (@height - 1) / Math.sqrt polygonNumber

    @options.deviation = 0.2 unless @options?.deviation?

    @vertices = d3.range @options.polygons or 100
      .map (d, i) =>
        ix = Math.floor i % (@width / columnHeight)
        iy = Math.floor i / @width * columnHeight

        centerX = ix * columnHeight + columnHeight / 2
        centerY = iy * lineHeight + lineHeight / 2

        x = d3.random.normal(centerX, columnHeight * @options.deviation)()
        y = d3.random.normal(centerY, lineHeight * @options.deviation)()

        @ensureInBounds x, y

    @voronoi = d3.geom.voronoi()
    .clipExtent [
        [0, 0]
        [@width, @height]
      ]

    @svg = d3.select 'body'
    .append 'svg'
    .attr 'width', @width
    .attr 'height', @height
    .style
      position: 'absolute'
      top: 0
      left: 0

    @pathGroup = @svg.append 'g'

    @updateDistribution()

  updateDistribution: ->
    path = @pathGroup.selectAll 'path'
    .data @voronoi(@vertices), @polygon

    path.exit()
    .remove()

    path.enter()
    .append 'path'
    .attr 'd', @polygon
    .style 'stroke-width', @options.strokeWidth or 1.51

    path.order()

    @updateColors()

  updateColors: ->
    @pathGroup.selectAll 'path'
    .each (d) =>
      colors = @getImageColors Math.round(d.point[0]), Math.round(d.point[1])
      d.color = "rgb(#{colors[0]},#{colors[1]},#{colors[2]})"
    .attr 'fill', (d) -> d.color
    .style 'stroke', (d) =>
      return d.color unless @options.stroke
      @options.stroke
    .style 'stroke-width', @options.strokeWidth or 1.51

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

window.StainedGlass = StainedGlass
