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
            {image, [{:translate, {dx, dy}} | transforms]}

          %{type: :rotate, angle: angle} ->
            angle_deg = angle * 180 / :math.pi()
            {image, [{:rotate, angle_deg} | transforms]}

          %{type: :scale, sx: sx, sy: sy} ->
            {image, [{:scale, {sx, sy}} | transforms]}

          shape ->
            {Sketch.Primitives.Render.render_png(shape, image, transforms), transforms}
        end
      end)

    image
  end

  def build_transform_opts(transform_opts) do
    Enum.reverse(transform_opts)
    |> Enum.map(fn
      {:rotate, angle} -> "rotate #{angle}"
      {:translate, {dx, dy}} -> "translate #{dx},#{dy}"
      {:scale, {sx, sy}} -> "scale #{sx},#{sy}"
    end)
    |> Enum.join(" ")
  end
end
