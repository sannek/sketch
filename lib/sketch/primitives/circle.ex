defmodule Sketch.Primitives.Circle do
  alias Sketch.Primitives.Error

  defstruct [:id, :origin, :diameter]

  @type coordinates :: {number, number}
  @type t :: %__MODULE__{
          id: any,
          origin: coordinates(),
          diameter: number()
        }

  def new(%{id: id} = params) do
    data = verify!(params)
    %__MODULE__{origin: data.origin, diameter: data.diameter, id: id}
  end

  def verify!(params) do
    case verify(params) do
      {:ok, data} -> data
      _ -> raise Error, message: info(params), data: params
    end
  end

  def verify(%{origin: {x, y}, diameter: d} = data)
      when is_number(x) and is_number(y) and is_number(d) do
    {:ok, data}
  end

  def verify(_), do: :invalid_data

  def info(data) do
    """
    #{__MODULE__} params should be: %{origin: {x, y}, diameter: d}, where x, y, and d are numbers.
    Received: #{inspect(data)}
    """
  end
end

defimpl Sketch.Render, for: Sketch.Primitives.Circle do
  def render_wx(circle, wx_context) do
    {x, y} = circle.origin
    center_x = x - circle.diameter / 2
    center_y = y - circle.diameter / 2

    :wxGraphicsContext.drawEllipse(
      wx_context,
      center_x,
      center_y,
      circle.diameter,
      circle.diameter
    )
  end

  def render_png(%{origin: {x, y}, diameter: d}, image, transforms) do
    ellipse_opts = to_string(:io_lib.format("~g,~g ~g,~g", [x / 1, y / 1, d / 2, d / 2]))

    transform_opts = Sketch.Render.Png.build_transform_opts(transforms)

    image
    |> Mogrify.custom("draw", "#{transform_opts} ellipse #{ellipse_opts} 0,360")
  end

  def render_svg(%{origin: {x, y}, diameter: d}) do
    {:circle, [cx: x, cy: y, r: d], []}
  end
end
