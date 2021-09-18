defmodule Sketch do
  defstruct title: "Sketch",
            width: 800,
            height: 600,
            background: {255, 255, 255},
            primitives: %{},
            order: []

  @moduledoc """
  Documentation for `Sketch`.
  """
  def new() do
    %__MODULE__{}
  end

  def run(%Sketch{} = sketch) do
    Sketch.Runner.start_link(sketch)
  end

  def line(%Sketch{} = sketch, params) do
    line = Sketch.Primitives.Line.new(params)

    add_shape(sketch, line)
  end

  def rect(%Sketch{} = sketch, params) do
    rect = Sketch.Primitives.Rect.new(params)

    add_shape(sketch, rect)
  end

  def square(%Sketch{} = sketch, params) do
    square = Sketch.Primitives.Square.new(params)

    add_shape(sketch, square)
  end

  def add_shape(sketch, shape) do
    primitives = Map.put_new(sketch.primitives, shape.id, shape)
    order = [shape.id | sketch.order]
    %{sketch | primitives: primitives, order: order}
  end
end
