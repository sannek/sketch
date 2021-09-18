defmodule Sketch.Render.Png do
  def render(sketch) do
    %Mogrify.Image{path: "#{sketch.title}.png", ext: "png"}
    |> Mogrify.custom("size", "#{sketch.width}x#{sketch.height}")
    |> Mogrify.canvas(Sketch.Color.to_hex(sketch.background))
    |> do_render(sketch)
    |> Mogrify.create(path: ".")
  end

  def do_render(image, sketch) do
    {image, _transforms} =
      Enum.reverse(sketch.order)
      |> Enum.reduce({image, []}, fn id, {image, transforms} ->
        case Map.get(sketch.items, id) do
          %{type: :fill, color: color} ->
            {Mogrify.custom(image, "fill", Sketch.Color.to_hex(color)), transforms}

          %{type: :translate, dx: dx, dy: dy} ->
            {ox, oy} = Keyword.get(transforms, :translate, {0, 0})
            {image, Keyword.put(transforms, :translate, {dx + ox, dy + oy})}

          shape ->
            {Sketch.Primitives.Render.render_png(shape, image, transforms), transforms}
        end
      end)

    image
  end
end
