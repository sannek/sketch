defmodule Sketch.Primitives.Ellipse do
  alias Sketch.Primitives.Error

  defstruct [:id, :origin, :width, :height]

  @type coordinates :: {number, number}
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
    #{__MODULE__} params should be: %{origin: {x, y}, width: w, height: h}, where x, y, w and h are numbers.
    Received: #{inspect(data)}
    """
  end
end

defimpl Sketch.Render, for: Sketch.Primitives.Ellipse do
  def render_wx(ellipse, wx_context) do
    {x, y} = ellipse.origin
    center_x = x - ellipse.width / 2
    center_y = y - ellipse.height / 2
    :wxGraphicsContext.drawEllipse(wx_context, center_x, center_y, ellipse.width, ellipse.height)
  end

  def render_png(%{origin: {x, y}, width: w, height: h}, image, transforms) do
    ellipse_opts = to_string(:io_lib.format("~g,~g ~g,~g", [x / 1, y / 1, w / 2, h / 2]))

    transform_opts = Sketch.Render.Png.build_transform_opts(transforms)

    image
    |> Mogrify.custom("draw", "#{transform_opts} ellipse #{ellipse_opts} 0,360")
  end
end
