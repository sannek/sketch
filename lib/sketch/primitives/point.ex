defmodule Sketch.Primitives.Point do
  alias Sketch.Primitives.Error
  defstruct [:id, :origin]
  @type coordinates :: {number(), number()}

  @type t :: %__MODULE__{
          id: any,
          origin: coordinates()
        }

  def new(params) do
    data = verify!(params)
    %__MODULE__{origin: data.origin, id: params.id}
  end

  def verify!(params) do
    case verify(params) do
      {:ok, data} -> data
      err -> raise Error, message: info(params), err: err, data: params
    end
  end

  def verify(%{origin: {x, y}} = data)
      when is_number(x) and is_number(y) do
    {:ok, data}
  end

  def verify(_), do: :invalid_data

  def info(data) do
    """
    #{__MODULE__} params should be: %{origin: {x, y}}, where x and y are numbers.
    Received: #{inspect(data)}
    """
  end
end

defimpl Sketch.Render, for: Sketch.Primitives.Point do
  def render_wx(point, wx_context) do
    # Line accepts floats so we need to convert
    %{origin: {startX, startY}} = point
    origin = {startX / 1, startY / 1}
    :wxGraphicsContext.drawLines(wx_context, [origin, origin])
  end

  def render_png(point, image, transforms) do
    # I cannot figure out how to draw a point the way I expect, so instead we
    # use the latest stroke colour and weight and use those to create a circel with no stroke
    # and the size and fill that we'd expect

    %{origin: {x, y}} = point

    color = get_stroke_color(image)
    size = get_strokewidth(image)

    transform_opts = Sketch.Render.Png.build_transform_opts(transforms)
    ellipse_opts = to_string(:io_lib.format("~g,~g ~g,~g", [x / 1, y / 1, size / 2, size / 2]))

    draw_command = """
    push graphic-context
    #{transform_opts}
    fill #{color} stroke none
    ellipse #{ellipse_opts} 0,360
    pop graphic-context
    """

    image
    |> Mogrify.custom("draw", draw_command)
  end

  defp get_stroke_color(%{operations: operations}) do
    Enum.reverse(operations)
    |> Enum.find_value(fn
      {"stroke", stroke} -> stroke
      _ -> false
    end)
  end

  defp get_strokewidth(%{operations: operations}) do
    Enum.reverse(operations)
    |> Enum.find_value(fn
      {"strokewidth", width} -> width
      _ -> false
    end)
  end
end
