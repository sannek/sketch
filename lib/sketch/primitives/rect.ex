defmodule Sketch.Primitives.Rect do
  alias Sketch.Primitives.Error

  defstruct [:id, :origin, :width, :height]

  @type coordinates :: {integer, integer}

  @type t :: %__MODULE__{
          id: any,
          origin: coordinates(),
          width: number(),
          height: number()
        }

  def new(%{origin: origin, width: width, height: height, id: id}) do
    %__MODULE__{origin: origin, width: width, height: height, id: id}
  end

  def verify!(params) do
    case verify(params) do
      {:ok, data} -> data
      err -> raise Error, message: info(params), err: err, data: params
    end
  end

  def verify(%{origin: {x, y}, width: w, height: h} = data)
      when is_number(x) and is_number(y) and is_number(w) and is_number(h) do
    {:ok, data}
  end

  def verify(_), do: :invalid_data

  def info(data) do
    """
    #{__MODULE__} params should be: %{origin: {x, y}, width: w, height: h}, where x, y, w, and h are numbers.
    Received: #{inspect(data)}
    """
  end
end

defimpl Sketch.Primitives.Render, for: Sketch.Primitives.Rect do
  def render_wx(rect, wx_context) do
    {x, y} = rect.origin
    :wxGraphicsContext.drawRectangle(wx_context, x, y, rect.width, rect.height)
  end

  def render_png(%{origin: {x, y}, width: w, height: h}, image, transforms) do
    rectangle_opts =
      to_string(:io_lib.format("~g,~g ~g,~g", [x / 1, y / 1, (x + w) / 1, (y + h) / 1]))

    transform_opts = Sketch.Render.Png.build_transform_opts(transforms)

    image
    |> Mogrify.custom("draw", "#{transform_opts} rectangle #{rectangle_opts}")
  end
end
