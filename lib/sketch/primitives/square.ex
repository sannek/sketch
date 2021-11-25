defmodule Sketch.Primitives.Square do
  alias Sketch.Primitives.Error
  defstruct [:id, :origin, :size]

  @type coordinates :: {number, number}
  @type t :: %__MODULE__{
          id: any,
          origin: coordinates(),
          size: number()
        }

  def new(%{id: id} = params) do
    data = verify!(params)
    %__MODULE__{origin: data.origin, size: data.size, id: id}
  end

  def verify!(params) do
    case verify(params) do
      {:ok, data} -> data
      _ -> raise Error, message: info(params), data: params
    end
  end

  def verify(%{origin: {x, y}, size: s} = data)
      when is_number(x) and is_number(y) and is_number(s) do
    {:ok, data}
  end

  def verify(_), do: :invalid_data

  def info(data) do
    """
    #{__MODULE__} params should be: %{origin: {x, y}, size: s}, where x, y, and s are numbers.
    Received: #{inspect(data)}
    """
  end
end

defimpl Sketch.Render, for: Sketch.Primitives.Square do
  def render_wx(square, wx_context) do
    {x, y} = square.origin
    :wxGraphicsContext.drawRectangle(wx_context, x, y, square.size, square.size)
  end

  def render_png(%{origin: {x, y}, size: s}, image, transforms) do
    square_opts =
      to_string(:io_lib.format("~g,~g ~g,~g", [x / 1, y / 1, (x + s) / 1, (y + s) / 1]))

    transform_opts = Sketch.Render.Png.build_transform_opts(transforms)

    image
    |> Mogrify.custom("draw", "#{transform_opts} rectangle #{square_opts}")
  end

  def render_svg(%{origin: {x, y}, size: s}) do
    {:rect, [x: x, y: y, width: s, height: s], []}
  end
end
