defprotocol Sketch.Primitives.Render do
  def render_wx(shape, context)

  def render_png(shape, image)
end
