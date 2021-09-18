defmodule Sketch.Primitives.Line do
  defstruct [:id, start: {0.0, 0.0}, finish: {10.0, 10.0}]

  def new(%{start: start, finish: finish}) do
    %__MODULE__{start: start, finish: finish, id: "line-#{:rand.uniform(100)}"}
  end
end

defimpl Sketch.Render, for: Sketch.Primitives.Line do
  def render_wx(line, wx_context) do
    :wxGraphicsContext.drawLines(wx_context, [line.start, line.finish])
  end
end
