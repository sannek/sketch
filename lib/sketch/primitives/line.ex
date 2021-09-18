defmodule Sketch.Primitives.Line do
  alias Sketch.Primitives.Error
  defstruct [:id, :start, :finish]
  @type coordinates :: {number(), number()}

  @type t :: %__MODULE__{
          id: any,
          start: coordinates(),
          finish: coordinates()
        }

  def new(params) do
    data = verify!(params)
    %__MODULE__{start: data.start, finish: data.finish, id: params.id}
  end

  def verify!(params) do
    case verify(params) do
      {:ok, data} -> data
      err -> raise Error, message: info(params), err: err, data: params
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

defimpl Sketch.Primitives.Render, for: Sketch.Primitives.Line do
  def render_wx(line, wx_context) do
    # Line accepts floats so we need to convert
    %{start: {startX, startY}, finish: {finishX, finishY}} = line
    start = {startX / 1, startY / 1}
    finish = {finishX / 1, finishY / 1}
    :wxGraphicsContext.drawLines(wx_context, [start, finish])
  end

  def render_png(line, image) do
    %{start: {startX, startY}, finish: {finishX, finishY}} = line

    opts =
      to_string(:io_lib.format("~g,~g ~g,~g", [startX / 1, startY / 1, finishX / 1, finishY / 1]))

    image
    |> Mogrify.custom("draw", "line #{opts}")
  end
end
