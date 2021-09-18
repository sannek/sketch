defmodule Sketch do
  defstruct title: "Sketch",
            width: 800,
            height: 600,
            background: {255, 255, 255},
            primitives: %{},
            order: []

  @type t :: %Sketch{
          title: String.t(),
          width: number,
          height: number,
          background: {integer, integer, integer},
          primitives: map,
          order: list
        }

  @type coordinates :: {number, number}

  @moduledoc """

  """

  @doc """
    Create a new Sketch
  """
  @spec new(opts :: list) :: Sketch.t()
  def new(opts \\ []) do
    %__MODULE__{
      title: Keyword.get(opts, :title, "Sketch"),
      width: Keyword.get(opts, :width, 800),
      height: Keyword.get(opts, :width, 600),
      background: Keyword.get(opts, :background, {255, 255, 255})
    }
  end

  @doc """
  Open a window to show the drawn sketch (using wxWidgets)
  """
  def run(%Sketch{} = sketch) do
    Sketch.Runner.start_link(sketch)
  end

  def save(%Sketch{} = sketch) do
    image =
      %Mogrify.Image{path: "#{sketch.title}.png", ext: "png"}
      |> Mogrify.custom("size", "#{sketch.width}x#{sketch.height}")
      |> Mogrify.canvas("#FFFFFF")
      |> Mogrify.custom("fill", "white")
      |> Mogrify.custom("stroke", "red")

    complete =
      Enum.reduce(sketch.order, image, fn id, image ->
        Map.get(sketch.primitives, id) |> Sketch.Primitives.Render.render_png(image)
      end)

    Mogrify.create(complete, path: ".")
  end

  def example do
    Sketch.new()
    |> Sketch.line(%{start: {0, 0}, finish: {100, 100}})
    |> Sketch.rect(%{origin: {40, 40}, width: 30, height: 30})
    |> Sketch.square(%{origin: {100, 100}, size: 50})
  end

  @doc """
  Add a line to a sketch
  """
  @spec line(Sketch.t(), %{start: coordinates(), finish: coordinates()}) :: Sketch.t()
  def line(%Sketch{} = sketch, params) do
    line = Sketch.Primitives.Line.new(params)

    add_shape(sketch, line)
  end

  @doc """
  Add a rectangle to a sketch
  """
  @spec rect(Sketch.t(), %{origin: coordinates(), width: integer(), height: integer()}) ::
          Sketch.t()
  def rect(%Sketch{} = sketch, params) do
    rect = Sketch.Primitives.Rect.new(params)

    add_shape(sketch, rect)
  end

  @doc """
  Add a square to a sketch. This is not meaningfullly different from adding a rectangle with the same width and height,
  but is a convenience function for readability.
  """
  @spec rect(Sketch.t(), %{origin: coordinates(), size: integer()}) ::
          Sketch.t()
  def square(%Sketch{} = sketch, params) do
    square = Sketch.Primitives.Square.new(params)

    add_shape(sketch, square)
  end

  @doc """
  Add any shape to a sketch. Usually it will be easier to use the helper functions for the individual primitives
  instead of using this directly, but this is exposed to allow custom shapes to be added.

  Note: custom shapes should Just Work™️, as long as they have an `:id` key, and implement the `Sketch.Render` protocol
  """
  def add_shape(sketch, shape) do
    primitives = Map.put_new(sketch.primitives, shape.id, shape)
    order = [shape.id | sketch.order]
    %{sketch | primitives: primitives, order: order}
  end
end
