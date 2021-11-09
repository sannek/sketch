defmodule Sketch do
  defstruct title: "Sketch",
            width: 800,
            height: 600,
            items: %{},
            order: [],
            background: Sketch.Color.new({120, 120, 120})

  @type sketch :: %Sketch{
          title: String.t(),
          width: number,
          height: number,
          background: Sketch.Color.t(),
          items: map,
          order: [integer()]
        }

  @typedoc """
  Color specified as `{r, g, b}` or `{r, g, b, a}`.
  rgb values will be clamped between 0-255,
  alpha expects a float between 0-1 (inclusive), where 0 is fully transparent and 1 is fully opaque.
  """
  @type color :: {integer, integer, integer} | {integer, integer, integer, number}
  @type coordinates :: {number, number}
  @type radians :: float

  @default_fill {255, 255, 255}
  @default_stroke_color {0, 0, 0}
  @default_stroke_weight 1

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
  @spec new(opts :: list) :: sketch()
  def new(opts \\ []) do
    background = Keyword.get(opts, :background, {120, 120, 120}) |> Sketch.Color.new()

    %__MODULE__{
      title: Keyword.get(opts, :title, "Sketch"),
      width: Keyword.get(opts, :width, 800),
      height: Keyword.get(opts, :height, 600),
      background: background
    }
    |> fill(@default_fill)
    |> stroke(@default_stroke_color)
    |> stroke_weight(@default_stroke_weight)
  end

  @doc """
  Open a window to show the sketch (using wxWidgets)
  """
  def run(%Sketch{} = sketch) do
    Sketch.Runner.start_link(sketch)
  end

  @doc """
  Save current sketch as png (requires ImageMagick to be installed locally)

  ## Options
  * `:timestamp` - whether or not the current timestamp should be affixed to the filename. Defaults to `true`, useful
  for sketches with random elements that do not produce the same output ever time. If `false` each save will overwrite
  the previous sketch

  """
  def save(%Sketch{} = sketch, opts \\ []) do
    filename = filename(sketch, "png", Keyword.get(opts, :timestamp, true))
    Sketch.Render.Png.render(sketch, filename, opts)
  end

  def save_svg(%Sketch{} = sketch, opts \\ []) do
    filename = filename(sketch, "svg", Keyword.get(opts, :timestamp, true))
    Sketch.Render.Svg.render(sketch, filename, opts)
  end

  defp filename(sketch, ext, true) do
    timestamp = DateTime.utc_now() |> DateTime.to_unix(:millisecond)
    "#{sketch.title}-#{timestamp}.#{ext}"
  end

  defp filename(sketch, ext, false) do
    "#{sketch.title}.#{ext}"
  end

  def example do
    new(background: {165, 122, 222})
    |> ellipse(%{origin: {0, 0}, width: 200, height: 100})
    |> translate({400, 300})
    |> fill({0, 120, 255, 0.5})
    |> no_stroke()
    |> circle(%{origin: {0, 0}, diameter: 50})
    |> no_fill()
    |> stroke({0, 255, 120})
    |> stroke_weight(5)
    |> point(%{origin: {0, 0}})
    |> circle(%{origin: {0, 0}, diameter: 250})
  end

  ######################
  ##                  ##
  ##    PRIMITIVES    ##
  ##                  ##
  ######################

  @doc """
  Add a point to a sketch. The size and color of the point are determined by stroke weight and color.
  """
  @spec point(sketch(), %{origin: coordinates()}) :: sketch()
  def point(%Sketch{} = sketch, params) do
    point = Map.put(params, :id, next_id(sketch)) |> Sketch.Primitives.Point.new()

    add_item(sketch, point)
  end

  @doc """
  Add a line to a sketch
  """
  @spec line(sketch(), %{start: coordinates(), finish: coordinates()}) :: sketch()
  def line(%Sketch{} = sketch, params) do
    line = Map.put(params, :id, next_id(sketch)) |> Sketch.Primitives.Line.new()

    add_item(sketch, line)
  end

  @doc """
  Add a rectangle to a sketch
  """
  @spec rect(sketch(), %{origin: coordinates(), width: integer(), height: integer()}) ::
          sketch()
  def rect(sketch, params) do
    rect = Map.put(params, :id, next_id(sketch)) |> Sketch.Primitives.Rect.new()

    add_item(sketch, rect)
  end

  @doc """
  Add a square to a sketch. This is not meaningfullly different from adding a rectangle with the same width and height,
  but is a convenience function for readability.
  """
  @spec square(sketch(), %{origin: coordinates(), size: integer()}) ::
          sketch()
  def square(%Sketch{} = sketch, params) do
    square = Map.put(params, :id, next_id(sketch)) |> Sketch.Primitives.Square.new()

    add_item(sketch, square)
  end

  @doc """
  Adds an ellipse to the sketch. The ellipse is drawn centered around the origin.
  """
  @spec ellipse(sketch(), %{origin: coordinates(), width: number(), height: number()}) ::
          sketch()
  def ellipse(sketch, params) do
    ellipse = Map.put(params, :id, next_id(sketch)) |> Sketch.Primitives.Ellipse.new()

    add_item(sketch, ellipse)
  end

  @doc """
  Adds a circle to the sketch. The circle is drawn centered around the origin.
  """
  @spec circle(sketch(), %{origin: coordinates(), diameter: number()}) ::
          sketch()
  def circle(sketch, params) do
    circle = Map.put(params, :id, next_id(sketch)) |> Sketch.Primitives.Circle.new()

    add_item(sketch, circle)
  end

  ######################
  ##                  ##
  ##      Styles      ##
  ##                  ##
  ######################

  @doc """
  Set the fill colour for any primitives following this function.
  """
  @spec fill(sketch(), color()) :: sketch()
  def fill(sketch, col) do
    fill = %{type: :fill, color: Sketch.Color.new(col), id: next_id(sketch)}
    add_item(sketch, fill)
  end

  @doc """
  Removes fill from any subsequent primitives.
  """
  @spec no_fill(sketch()) :: sketch()
  def no_fill(sketch) do
    fill = %{type: :no_fill, id: next_id(sketch)}
    add_item(sketch, fill)
  end

  @doc """
  Sets the stroke colour for any subsequent primitives
  """
  @spec stroke(sketch(), color()) :: sketch()
  def stroke(sketch, col) do
    stroke = %{type: :stroke, color: Sketch.Color.new(col), id: next_id(sketch)}
    add_item(sketch, stroke)
  end

  @doc """
  Sets the stroke weight for any subsequent primitives
  """
  @spec stroke_weight(sketch(), number()) :: sketch()
  def stroke_weight(sketch, weight) do
    stroke_weight = %{type: :stroke_weight, weight: weight, id: next_id(sketch)}
    add_item(sketch, stroke_weight)
  end

  @doc """
  Removes the stroke from any subsequent primitives
  """
  @spec no_stroke(sketch()) :: sketch()
  def no_stroke(sketch) do
    stroke = %{type: :no_stroke, id: next_id(sketch)}
    add_item(sketch, stroke)
  end

  ######################
  ##                  ##
  ##    Transforms    ##
  ##                  ##
  ######################

  @doc """
  Moves the origin by dx, dy. Before any translations are applied, the origin {0,0} is in the top left of the sketch

  Stacks with other transforms, until Sketch.reset_matrix/1 is called to clear all transforms.
  """
  @spec translate(sketch(), {number(), number()}) :: sketch()
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
  @spec rotate(sketch(), radians()) :: sketch()
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
  @spec scale(sketch(), number() | {number(), number()}) :: sketch()
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
  @spec reset_matrix(sketch()) :: sketch()
  def reset_matrix(sketch) do
    add_item(sketch, %{type: :reset_matrix, id: next_id(sketch)})
  end

  ######################
  ##                  ##
  ##      Other       ##
  ##                  ##
  ######################

  @doc """
  Add any operation to a sketch. Usually it will be easier to use the helper functions for the individual primitives
  instead of using this directly, but this is exposed to allow custom shapes to be added.

  Note: custom operations should Just Work™️, as long as they have an `:id` key, and implement the `Sketch.Render` protocol
  """
  def add_item(sketch, item) do
    items = Map.put_new(sketch.items, item.id, item)
    order = [item.id | sketch.order]
    %{sketch | items: items, order: order}
  end

  defp next_id(%{order: []}), do: 1

  defp next_id(%{order: [prev | _]}) do
    prev + 1
  end
end
