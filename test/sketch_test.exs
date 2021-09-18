defmodule SketchTest do
  use ExUnit.Case
  doctest Sketch

  test "greets the world" do
    assert Sketch.hello() == :world
  end
end
