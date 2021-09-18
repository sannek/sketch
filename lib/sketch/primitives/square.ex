defmodule Sketch.Primitives.Square do
  defstruct [:id, origin: {0.0, 0.0}, size: 10.0]

  def new(%{origin: origin, size: size}) do
    %__MODULE__{origin: origin, size: size, id: "square-#{:rand.uniform(100)}"}
  end
end

defimpl Sketch.Render, for: Sketch.Primitives.Square do
  def render_wx(square, wx_context) do
    {x, y} = square.origin
    :wxGraphicsContext.drawRectangle(wx_context, x, y, square.size, square.size)
  end
end
