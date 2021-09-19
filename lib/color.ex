defmodule Sketch.Color do
  defstruct [:r, :g, :b, :a]

  @type t :: %__MODULE__{
          r: integer(),
          g: integer(),
          b: integer(),
          a: float()
        }

  def new({r, g, b}) do
    new({r, g, b, 1.0})
  end

  def new({r, g, b, a}) do
    %__MODULE__{
      r: normalize(r),
      g: normalize(g),
      b: normalize(b),
      a: alpha_normalize(a)
    }
  end

  def to_hex(%{r: r, g: g, b: b, a: a}) do
    "\##{hex(r)}#{hex(g)}#{hex(b)}#{hex(floor(a * 255))}"
  end

  def to_tuple(%{r: r, g: g, b: b, a: a}) do
    {r, g, b, floor(a * 255)}
  end

  defp normalize(n) when is_integer(n) and n < 0, do: 0
  defp normalize(n) when is_integer(n) and n > 255, do: 255
  defp normalize(n) when is_integer(n), do: n

  defp normalize(n),
    do: raise(ArgumentError, "Invalid colour value, expected an integer, got: #{inspect(n)}")

  defp alpha_normalize(a) when is_number(a) and a <= 1 and a >= 0, do: a / 1

  defp alpha_normalize(a),
    do:
      raise(
        ArgumentError,
        "Invalid alpha value, expected an number between 0 and 1, got: #{inspect(a)}"
      )

  defp hex(n) do
    Integer.to_string(n, 16)
    |> String.pad_leading(2, "0")
  end
end
