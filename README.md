# Sketch

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `sketch` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:sketch, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/sketch](https://hexdocs.pm/sketch).

## How to use

1. Create a canvas with `Sketch.new`
2. Draw the rest of the fucking owl

```
Sketch.new
|> Sketch.square(%{origin: {0, 0}, size: 50})
|> Sketch.run
```

This will draw a square with its top left corner at x 0, y 0 and a width and height of 50.

To add more shapes to the canvas, just keep piping:

```
Sketch.new
|> Sketch.square(%{origin: {0, 0}, size: 50})
|> Sketch.rect(%{origin: {0, 0}, width: 10, height: 20})
|> Sketch.line(%{start: {0, 0}, finish: {50, 50}})
|> Sketch.run
```

[Insert beautiful drawing here]