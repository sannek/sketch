defmodule Sketch.Primitives.Line do
  alias Sketch.Primitives.Error
  defstruct [:id, :start, :finish]
  @type coordinates :: {number(), number()}

  @type t :: %__MODULE__{
          id: any,
          start: coordinates(),
          finish: coordinates()
        }

  def new(%{id: id} = params) do
    data = verify!(params)
    %__MODULE__{start: data.start, finish: data.finish, id: id}
  end

  def verify!(params) do
    case verify(params) do
      {:ok, data} -> data
      _err -> raise Error, message: info(params), data: params
    end
  end

  def verify(%{start: {sx, sy}, finish: {fx, fy}} = data)
      when is_number(sx) and is_number(sy) and is_number(fx) and is_number(fy) do
    {:ok, data}
  end

  def verify(_), do: :invalid_data

  def info(data) do
    """
    #{__MODULE__} params should be: %{start: {x, y}, finish: {x, y}}, where all x and y are numbers.
    Received: #{inspect(data)}
    """
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

  def render_png(line, image, transforms) do
    %{start: {startX, startY}, finish: {finishX, finishY}} = line

    line_opts =
      to_string(:io_lib.format("~g,~g ~g,~g", [startX / 1, startY / 1, finishX / 1, finishY / 1]))

    transform_opts = Sketch.Render.Png.build_transform_opts(transforms)

    image
    |> Mogrify.custom("draw", "#{transform_opts} line #{line_opts}")
  end

  def render_svg(line) do
    %{start: {x1, y1}, finish: {x2, y2}} = line
    {:line, [x1: x1, y1: y1, x2: x2, y2: y2], []}
  end
end
