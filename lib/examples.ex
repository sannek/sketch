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
