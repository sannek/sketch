defmodule Sketch.Color do
  defstruct [:r, :g, :b]

  @type t :: %__MODULE__{
          r: integer(),
          g: integer(),
          b: integer()
        }

  def new({r, g, b}) do
    %__MODULE__{
      r: normalize(r),
      g: normalize(g),
      b: normalize(b)
    }
  end

  def to_hex(%{r: r, g: g, b: b}) do
    "\##{hex(r)}#{hex(g)}#{hex(b)}"
  end

  def to_tuple(%{r: r, g: g, b: b}) do
    {r, g, b}
  end

  defp hex(n) do
    Integer.to_string(n, 16)
    |> String.pad_leading(2, ["0"])
  end

  defp normalize(n) when is_integer(n) and n < 0, do: 0
  defp normalize(n) when is_integer(n) and n > 255, do: 255
  defp normalize(n) when is_integer(n), do: n
  defp normalize(n), do: raise(ArgumentError, "Invalid colour value: #{inspect(n)}")
end
