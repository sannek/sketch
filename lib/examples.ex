defmodule Examples do
  import Sketch

  @doc """
  Draws a [Maurer rose](https://en.wikipedia.org/wiki/Maurer_rose)
  """
  def maurer_rose(n, d) do
    radius = 300

    new(width: 800, height: 800, background: {255, 237, 211}, title: "maurer_rose")
    |> translate({400, 400})
    |> stroke({254, 143, 143})
    |> add_rose_lines(n, d, radius)
    |> stroke({255, 92, 88})
    |> stroke_weight(3)
    |> add_second_rose_lines(n, radius)
  end

  def barnsley_fern(detail \\ 100) do
    new(width: 600, height: 600, title: "barnsley_fern", background: {234, 231, 217})
    |> stroke({147, 125, 20})
    |> stroke_weight(2)
    |> add_fern_points(detail)
  end

  def candy_dots(count \\ 5) do
    new(width: 600, height: 600, title: "tiles", background: {255, 255, 255})
    |> no_stroke()
    |> add_tiles(count)
  end

  defp add_tiles(sketch, count) do
    margin = min(sketch.width, sketch.height) / 10
    tile_width = (sketch.width - 2 * margin) / count
    tile_height = (sketch.height - 2 * margin) / count

    for i <- 0..(count - 1), j <- 0..(count - 1), reduce: sketch do
      sketch ->
        sketch
        |> reset_matrix()
        |> translate({i * tile_width + margin, j * tile_height + margin})
        |> add_tile({tile_width, tile_height})
    end
  end

  defp add_tile(sketch, {w, h}) do
    palette = [
      {111, 105, 172},
      {149, 218, 193},
      {255, 235, 161},
      {253, 111, 150}
    ]

    [first, second | _] = Enum.shuffle(palette)

    diameter = Sketch.Math.remap(0.4, {0, 1}, {0, w})
    x_jitter = Sketch.Math.remap(:rand.uniform(), {0, 1}, {-w / 5, w / 5})
    y_jitter = Sketch.Math.remap(:rand.uniform(), {0, 1}, {-w / 5, w / 5})

    first_origin = {w / 2, h / 2}
    second_origin = {w / 2 + x_jitter, h / 2 + y_jitter}

    sketch
    |> fill(first)
    |> circle(%{origin: first_origin, diameter: diameter})
    |> fill(second)
    |> circle(%{origin: second_origin, diameter: diameter})
  end

  defp add_fern_points(sketch, detail) do
    {sketch, _} =
      for _ <- 1..detail, reduce: {sketch, {0, 0}} do
        {sketch, coords} ->
          {add_fern_point(sketch, coords), next_point(coords)}
      end

    sketch
  end

  defp add_fern_point(sketch, {x, y}) do
    mx = sketch.width * (x + 3) / 6
    my = sketch.height - sketch.height * ((y + 2) / 14)

    point(sketch, %{origin: {mx, my}})
  end

  defp next_point({px, py}) do
    case :rand.uniform() do
      r when r < 0.01 ->
        x = 0
        y = py * 0.16
        {x, y}

      r when r < 0.86 ->
        x = 0.85 * px + 0.04 * py
        y = -0.04 * px + 0.85 * py + 1.6
        {x, y}

      r when r < 0.93 ->
        x = 0.20 * px - 0.26 * py
        y = 0.23 * px + 0.22 * py + 1.6
        {x, y}

      _ ->
        x = -0.15 * px + 0.28 * py
        y = 0.26 * px + 0.24 * py + 0.44
        {x, y}
    end
  end

  defp add_rose_lines(sketch, n, d, radius) do
    {sketch, _} =
      for theta <- 0..360, reduce: {sketch, {0, 0}} do
        {sketch, previous} ->
          k = theta * d * :math.pi() / 180
          r = radius * :math.sin(n * k)
          x = -r * :math.cos(k)
          y = -r * :math.sin(k)
          new_sketch = line(sketch, %{start: previous, finish: {x, y}})
          {new_sketch, {x, y}}
      end

    sketch
  end

  defp add_second_rose_lines(sketch, n, radius) do
    {sketch, _} =
      for theta <- 0..360, reduce: {sketch, {0, 0}} do
        {sketch, previous} ->
          k = theta * :math.pi() / 180
          r = radius * :math.sin(n * k)
          x = r * :math.cos(k)
          y = -r * :math.sin(k)
          new_sketch = line(sketch, %{start: previous, finish: {x, y}})
          {new_sketch, {x, y}}
      end

    sketch
  end
end
