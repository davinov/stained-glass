class StainedGlass
  constructor: (@img, options) ->
    {@width, @height} = @img
    @mapImageColors()
    @generateDistribution()

  polygon: (d) -> "M#{d.join 'L'}Z"

  generateDistribution: ->
    @vertices = d3.range 100
    .map (d) => [Math.random() * @width, Math.random() * @height]

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

    path.order()

    @updateColors()

  updateColors: ->
    @pathGroup.selectAll 'path'
    .attr 'fill', (d) =>
      colors = @getImageColors Math.round(d.point[0]), Math.round(d.point[1])
      return "rgb(#{colors[0]},#{colors[1]},#{colors[2]})"

  mapImageColors: ->
    @canvas = document.createElement 'canvas'

    @canvas.width = @width
    @canvas.height = @height

    @canvas.getContext '2d'
    .drawImage @img, 0, 0, @width, @height

  getImageColors: (x, y) ->
    # Ensure bound are not crossed
    x = d3.max [0, x]
    y = d3.max [0, y]
    x = d3.min [x, @width - 1]
    y = d3.min [y, @height - 1]

    @canvas.getContext '2d'
    .getImageData x, y, 1, 1
    .data

window.StainedGlass = StainedGlass
