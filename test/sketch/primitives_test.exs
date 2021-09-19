defmodule Sketch.PrimitivesTest do
  use ExUnit.Case
  alias Sketch.Primitives

  describe "Circle" do
    test "generates a Circle when given valid parameters" do
      params = %{
        origin: {:rand.uniform(100), :rand.uniform(100)},
        diameter: :rand.uniform(100),
        id: :rand.uniform(10)
      }

      circle = Primitives.Circle.new(params)

      assert circle.origin == params.origin
      assert circle.diameter == params.diameter
      assert circle.id == params.id
    end

    test "raises a readable error when given invalid parameters" do
      invalid_params = %{origin: {"a", "b"}, diameter: :big, id: :rand.uniform(10)}

      assert_raise Primitives.Error, ~r/params should be:/, fn ->
        Primitives.Circle.new(invalid_params)
      end
    end
  end

  describe "Ellipse" do
    test "generates an Ellipse when given valid parameters" do
      params = %{
        origin: {:rand.uniform(100), :rand.uniform(100)},
        width: :rand.uniform(100),
        height: :rand.uniform(100),
        id: :rand.uniform(10)
      }

      ellipse = Primitives.Ellipse.new(params)

      assert ellipse.origin == params.origin
      assert ellipse.width == params.width
      assert ellipse.height == params.height
      assert ellipse.id == params.id
    end

    test "raises a readable error when given invalid parameters" do
      invalid_params = %{origin: {"a", "b"}, width: :big, height: 100, id: :rand.uniform(10)}

      assert_raise Primitives.Error, ~r/params should be:/, fn ->
        Primitives.Ellipse.new(invalid_params)
      end
    end
  end

  describe "Square" do
    test "generates a Square when given valid parameters" do
      params = %{
        origin: {:rand.uniform(100), :rand.uniform(100)},
        size: :rand.uniform(100),
        id: :rand.uniform(10)
      }

      square = Primitives.Square.new(params)

      assert square.origin == params.origin
      assert square.size == params.size
      assert square.id == params.id
    end

    test "raises a readable error when given invalid parameters" do
      invalid_params = %{origin: {"a", "b"}, size: :big, id: :rand.uniform(10)}

      assert_raise Primitives.Error, ~r/params should be:/, fn ->
        Primitives.Square.new(invalid_params)
      end
    end
  end

  describe "Rect" do
    test "generates a Rectangle when given valid parameters" do
      params = %{
        origin: {:rand.uniform(100), :rand.uniform(100)},
        width: :rand.uniform(100),
        height: :rand.uniform(100),
        id: :rand.uniform(10)
      }

      rect = Primitives.Rect.new(params)

      assert rect.origin == params.origin
      assert rect.width == params.width
      assert rect.height == params.height
      assert rect.id == params.id
    end

    test "raises a readable error when given invalid parameters" do
      invalid_params = %{origin: {"a", "b"}, width: :big, height: 100, id: :rand.uniform(10)}

      assert_raise Primitives.Error, ~r/params should be:/, fn ->
        Primitives.Rect.new(invalid_params)
      end
    end
  end

  describe "Line" do
    test "generates a Line when given valid parameters" do
      params = %{
        start: {:rand.uniform(100), :rand.uniform(100)},
        finish: {:rand.uniform(100), :rand.uniform(100)},
        id: :rand.uniform(10)
      }

      line = Primitives.Line.new(params)

      assert line.start == params.start
      assert line.finish == params.finish
      assert line.id == params.id
    end

    test "raises a readable error when given invalid parameters" do
      invalid_params = %{start: {"a", "b"}, finish: :big, id: :rand.uniform(10)}

      assert_raise Primitives.Error, ~r/params should be:/, fn ->
        Primitives.Line.new(invalid_params)
      end
    end
  end

  describe "Point" do
    test "generates a Point when given valid parameters" do
      params = %{
        origin: {:rand.uniform(100), :rand.uniform(100)},
        id: :rand.uniform(10)
      }

      point = Primitives.Point.new(params)

      assert point.origin == params.origin
      assert point.id == params.id
    end

    test "raises a readable error when given invalid parameters" do
      invalid_params = %{origin: {"a", "b"}, id: :rand.uniform(10)}

      assert_raise Primitives.Error, ~r/params should be:/, fn ->
        Primitives.Point.new(invalid_params)
      end
    end
  end
end
