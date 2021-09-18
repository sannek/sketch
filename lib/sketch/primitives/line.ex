defmodule Sketch.Primitives.Line do
  defstruct [:id, start: {0, 0}, finish: {10, 10}]

  def new(%{start: start, finish: finish}) do
    %__MODULE__{start: start, finish: finish, id: "line-#{:rand.uniform(100)}"}
  end
end

defimpl Sketch.Render, for: Sketch.Primitives.Line do
  def render_wx(line, wx_context) do
    # Line accepts floats so we need to convert
    %{start: {startX, startY}, finish: {finishX, finishY}} = line
    start = {startX / 1, startY / 1}
    finish = {finishX / 1, finishY / 1}
    :wxGraphicsContext.drawLines(wx_context, [start, finish])
  end
end
