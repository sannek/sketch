defmodule Sketch.Math do
  @doc ~S"""
  Calculates a number at a specific point between two numbers. If the amount is larger than 1.0, or smaller than 0.0,
  the result will be similarly outside of the range start..stop.

  ## Examples

    iex> Sketch.Math.lerp(0, 100, 0.5)
    50.0

    iex> Sketch.Math.lerp(0, 100, 2)
    200.0
  """
  @spec lerp(number(), number(), number()) :: float()
  def lerp(start, stop, amount) when is_number(start) and is_number(stop) and is_number(amount) do
    (amount * (stop - start) + start) / 1
  end

  @doc ~S"""
  Remaps a number from one range to another.

  ## Options
  * `:constrain` whether or not output value should be restrained to the new range. Defaults to false

  ##  Examples

    iex> Sketch.Math.remap(5, {0, 10}, {50, 100})
    75.0

    iex> Sketch.Math.remap(10, {0, 5}, {0, 10})
    20.0

    iex> Sketch.Math.remap(10, {0, 5}, {0, 10}, constrain: true)
    10.0

  """
  @spec remap(number(), {number(), number()}, {number(), number()}) :: float()
  def remap(value, {start1, stop1} = _from, {start2, stop2} = _to, opts \\ []) do
    new_value = (value - start1) / (stop1 - start1) * (stop2 - start2) + start2

    if Keyword.get(opts, :constrain) do
      constrain(new_value, min(start2, stop2), max(start2, stop2)) / 1
    else
      new_value
    end
  end

  def constrain(value, _min, max) when value > max, do: max
  def constrain(value, min, _max) when value < min, do: min
  def constrain(value, _min, _max), do: value
end
