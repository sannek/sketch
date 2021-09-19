defmodule Sketch do
  defstruct title: "Sketch",
            width: 800,
            height: 600,
            items: %{},
            order: [],
            background: Sketch.Color.new({120, 120, 120})

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
   Create a new Sketch struct to be used for further operations.

   ## Options
   * `:title` - The title of the sketch, defaults to "Sketch"
   * `:width` - Width of the sketch in pixels, defaults to 800
   * `:height` - Height of the sketch in pixels, defaults to 600
   * `:background` - Background colour of the sketch as a `{r, g, b}` tuple, defaults to `{120, 120, 120}` (a medium gray)
  """
  @spec new(opts :: list) :: Sketch.t()
  def new(opts \\ []) do
    background = Keyword.get(opts, :background, {120, 120, 120}) |> Sketch.Color.new()

    %__MODULE__{
      title: Keyword.get(opts, :title, "Sketch"),
      width: Keyword.get(opts, :width, 800),
      height: Keyword.get(opts, :height, 600),
      background: background
    }
  end

  @doc """
  Open a window to show the sketch (using wxWidgets)
  """
  def run(%Sketch{} = sketch) do
    Sketch.Runner.start_link(sketch)
  end

  @doc """
  Save current sketch as png (requires ImageMagick to be installed locally)
  """
  def save(%Sketch{} = sketch) do
    Sketch.Render.Png.render(sketch)
  end

  def example do
    Sketch.new(background: {165, 122, 222})
    |> Sketch.translate({400, 300})
    |> Sketch.set_fill({0, 120, 255})
    |> Sketch.square(%{origin: {0, 0}, size: 50})
    |> Sketch.set_fill({30, 50, 89})
    |> Sketch.rotate(:math.pi() / 8)
    |> Sketch.square(%{origin: {0, 0}, size: 50})
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

  @doc """
  Set the fill colour for any primitives following this function.
  """
  def set_fill(sketch, {_r, _g, _b} = col) do
    fill = %{type: :fill, color: Sketch.Color.new(col), id: next_id(sketch)}
    add_item(sketch, fill)
  end

  @doc """
  Moves the origin by dx, dy. Before any translations are applied, the origin {0,0} is in the top left of the sketch

  Stacks with other transforms, until Sketch.reset_matrix/1 is called to clear all transforms.
  """
  @spec translate(Sketch.t(), {number(), number()}) :: Sketch.t()
  def translate(sketch, {dx, dy}) do
    translate = %{
      type: :translate,
      dx: dx,
      dy: dy,
      id: next_id(sketch)
    }

    add_item(sketch, translate)
  end

  @doc """
  Rotates the canvas clockwise around the current origin ({0,0} by default, but this can be moved with Sketch.translate/2).

  The `angle` is assumed to be in radians!

  Stacks with other transforms, until Sketch.reset_matrix/1 is called to clear all transforms.
  """
  @spec rotate(Sketch.t(), radians()) :: Sketch.t()
  def rotate(sketch, angle) do
    rotate = %{
      type: :rotate,
      angle: angle,
      id: next_id(sketch)
    }

    add_item(sketch, rotate)
  end

  @doc """
  Scales the canvas.

  Examples:
  - `Sketch.scale(sketch, 2)` will scale uniformly by 2 along both the x and y axis
  - `Sketch.scale(sketch, {2, 2})` will scale uniformly by 2 along both the x and y axis
  - `Sketch.scale(sketch, {2, 1})` will scale by 2 along the x-axis, but not along the y-axis
  - `Sketch.scale(sketch, {-1, 1})` will flip the drawing along the x-axis

  Stacks with other transforms, until Sketch.reset_matrix/1 is called to clear all transforms.
  """
  @spec scale(Sketch.t(), number() | {number(), number()}) :: Sketch.t()
  def scale(sketch, xy_scale) when is_number(xy_scale) do
    scale(sketch, {xy_scale, xy_scale})
  end

  def scale(sketch, {sx, sy}) when is_number(sx) and is_number(sy) do
    scale_props = %{type: :scale, sx: sx, sy: sy, id: next_id(sketch)}
    add_item(sketch, scale_props)
  end

  @doc """
  Resets the current transformation matrix for the sketch, removing all transformations (translate, scale, rotate etc.) that
  have been applied until this point.
  """
  @spec reset_matrix(Sketch.t()) :: Sketch.t()
  def reset_matrix(sketch) do
    add_item(sketch, %{type: :reset_matrix, id: next_id(sketch)})
  end

  defp next_id(%{order: []}), do: 1

  defp next_id(%{order: [prev | _]}) do
    prev + 1
  end
end
