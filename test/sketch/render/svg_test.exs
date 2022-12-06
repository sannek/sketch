defmodule Sketch.Render.SvgTest do
  use ExUnit.Case

  alias Sketch.Render.Svg

  test "it renders SVG" do
    svg =
      Sketch.new()
      |> Sketch.fill({255, 0, 0})
      |> Sketch.circle(%{origin: {10, 10}, diameter: 10})
      |> Svg.render_to_string()

    File.write!("/home/arjan/test.svg", svg)

    IO.inspect(svg, label: "svg")
  end
end
