defmodule Sketch do
  defstruct title: "Sketch",
            width: 800,
            height: 600,
            items: %{},
            order: [],
            background: Sketch.Color.new({255, 255, 255})

  @type t :: %Sketch{
          title: String.t(),
          width: number,
          height: number,
          background: Sketch.Color.t(),
          items: map,
          order: [integer()]
        }

  @type coordinates :: {number, number}
  @type radians :: float
  @moduledoc """

  """

  @doc """
    Create a new Sketch
  """
  @spec new(opts :: list) :: Sketch.t()
  def new(opts \\ []) do
    background = Keyword.get(opts, :background, {255, 255, 255}) |> Sketch.Color.new()

    %__MODULE__{
      title: Keyword.get(opts, :title, "Sketch"),
      width: Keyword.get(opts, :width, 800),
      height: Keyword.get(opts, :height, 600),
      background: background
    }
  end

  @doc """
  Open a window to show the drawn sketch (using wxWidgets)
  """
  def run(%Sketch{} = sketch) do
    Sketch.Runner.start_link(sketch)
  end

  def save(%Sketch{} = sketch) do
    Sketch.Render.Png.render(sketch)
  end

  def example do
    Sketch.new(background: {165, 122, 222})
    |> Sketch.line(%{start: {0, 0}, finish: {100, 100}})
    |> Sketch.set_fill({200, 120, 0})
    |> Sketch.rect(%{origin: {40, 40}, width: 30, height: 30})
    |> Sketch.translate(50, 50)
    |> Sketch.set_fill({0, 120, 255})
    |> Sketch.square(%{origin: {0, 0}, size: 50})
    |> Sketch.set_fill({30, 50, 89})
    |> Sketch.rotate(0.5)
    |> Sketch.square(%{origin: {0, 0}, size: 50})
    |> Sketch.reset_matrix()
    |> Sketch.set_fill({80, 123, 200})
    |> Sketch.square(%{origin: {250, 250}, size: 70})
  end

  @doc """
  Add a line to a sketch
  """
  @spec line(Sketch.t(), %{start: coordinates(), finish: coordinates()}) :: Sketch.t()
  def line(%Sketch{} = sketch, params) do
    line = Map.put(params, :id, next_id(sketch)) |> Sketch.Primitives.Line.new()

    add_item(sketch, line)
  end

  @doc """
  Add a rectangle to a sketch
  """
  @spec rect(Sketch.t(), %{origin: coordinates(), width: integer(), height: integer()}) ::
          Sketch.t()
  def rect(sketch, params) do
    rect = Map.put(params, :id, next_id(sketch)) |> Sketch.Primitives.Rect.new()

    add_item(sketch, rect)
  end

  @doc """
  Add a square to a sketch. This is not meaningfullly different from adding a rectangle with the same width and height,
  but is a convenience function for readability.
  """
  @spec square(Sketch.t(), %{origin: coordinates(), size: integer()}) ::
          Sketch.t()
  def square(%Sketch{} = sketch, params) do
    square = Map.put(params, :id, next_id(sketch)) |> Sketch.Primitives.Square.new()

    add_item(sketch, square)
  end

  @doc """
  Add any shape to a sketch. Usually it will be easier to use the helper functions for the individual primitives
  instead of using this directly, but this is exposed to allow custom shapes to be added.

  Note: custom shapes should Just Work™️, as long as they have an `:id` key, and implement the `Sketch.Render` protocol
  """
  def add_item(sketch, item) do
    items = Map.put_new(sketch.items, item.id, item)
    order = [item.id | sketch.order]
    %{sketch | items: items, order: order}
  end

  def set_fill(sketch, {_r, _g, _b} = col) do
    fill = %{type: :fill, color: Sketch.Color.new(col), id: next_id(sketch)}
    add_item(sketch, fill)
  end

  def translate(sketch, dx, dy) do
    translate = %{
      type: :translate,
      dx: dx,
      dy: dy,
      id: next_id(sketch)
    }

    add_item(sketch, translate)
  end

  @spec rotate(Sketch.t(), radians()) :: Sketch.t()
  def rotate(sketch, angle) do
    rotate = %{
      type: :rotate,
      angle: angle,
      id: next_id(sketch)
    }

    add_item(sketch, rotate)
  end

  def scale(sketch, xy_scale) do
    scale(sketch, xy_scale, xy_scale)
  end

  def scale(sketch, sx, sy) do
    scale_props = %{type: :scale, sx: sx, sy: sy, id: next_id(sketch)}
    add_item(sketch, scale_props)
  end

  def reset_matrix(sketch) do
    add_item(sketch, %{type: :reset_matrix, id: next_id(sketch)})
  end

  defp next_id(%{order: []}), do: 1

  defp next_id(%{order: [prev | _]}) do
    prev + 1
  end
end
