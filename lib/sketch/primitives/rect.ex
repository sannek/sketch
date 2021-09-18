defmodule Sketch.Primitives.Rect do
  defstruct [:id, origin: {0.0, 0.0}, width: 10.0, height: 10.0]

  def new(%{origin: origin, width: width, height: height}) do
    %__MODULE__{origin: origin, width: width, height: height, id: "rect-#{:rand.uniform(100)}"}
  end
end

defimpl Sketch.Render, for: Sketch.Primitives.Rect do
  def render_wx(rect, wx_context) do
    {x, y} = rect.origin
    :wxGraphicsContext.drawRectangle(wx_context, x, y, rect.width, rect.height)
  end
end
