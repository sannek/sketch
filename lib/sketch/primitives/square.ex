defmodule Sketch.Primitives.Square do
  alias Sketch.Primitives.Error
  defstruct [:id, :origin, :size]

  @type coordinates :: {number, number}
  @type t :: %__MODULE__{
          id: any,
          origin: coordinates(),
          size: number()
        }

  def new(%{origin: origin, size: size}) do
    %__MODULE__{origin: origin, size: size, id: "square-#{:rand.uniform(100)}"}
  end

  def verify!(params) do
    case verify(params) do
      {:ok, data} -> data
      err -> raise Error, message: info(params), err: err, data: params
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

defimpl Sketch.Primitives.Render, for: Sketch.Primitives.Square do
  def render_wx(square, wx_context) do
    {x, y} = square.origin
    :wxGraphicsContext.drawRectangle(wx_context, x, y, square.size, square.size)
  end

  def render_png(%{origin: {x, y}, size: s}, image) do
    opts = to_string(:io_lib.format("~g,~g ~g,~g", [x / 1, y / 1, (x + s) / 1, (y + s) / 1]))

    image
    |> Mogrify.custom("draw", "rectangle #{opts}")
  end
end
