# StainedGlass
Awesome stained pictures are no more exclusivity of church.

For a nice replacement, ensure that you have no particular styles on the `img` element,
or apply the same to `.stained-glass`.

```JavaScript
  new StainedGlass(HTMLImageElement, [options]);
```

`options`:
- `deviation`: irregularity of the shapes (default 0.2)
- `polygons`: number of created polygons (default 100)
- `stroke`: default same as the fill color
- `strokeWidth`: (default 1.51)
- `triangles`: generate Delaunay vertices instead of Voronoï (default false)
