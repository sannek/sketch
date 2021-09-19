defmodule SketchTest do
  use ExUnit.Case
  doctest Sketch

  test "initialises a Sketch with specified valid options" do
    sketch = Sketch.new(width: 100, height: 200, title: "title")

    assert sketch.width == 100
    assert sketch.height == 200
    assert sketch.title == "title"
  end
end
