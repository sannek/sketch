defmodule Sketch.Render.Png do
  def render(sketch, filename, opts) do
    %Mogrify.Image{path: filename, ext: "png"}
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

          %{type: :no_fill} ->
            {Mogrify.custom(image, "fill", "none"), transforms}

          %{type: :stroke, color: color} ->
            {Mogrify.custom(image, "stroke", Sketch.Color.to_hex(color)), transforms}

          %{type: :stroke_weight, weight: weight} ->
            {Mogrify.custom(image, "strokewidth", weight), transforms}

          %{type: :no_stroke} ->
            {Mogrify.custom(image, "stroke", "none"), transforms}

          %{type: :translate, dx: dx, dy: dy} ->
            {image, [{:translate, {dx, dy}} | transforms]}

          %{type: :rotate, angle: angle} ->
            angle_deg = angle * 180 / :math.pi()
            {image, [{:rotate, angle_deg} | transforms]}

          %{type: :scale, sx: sx, sy: sy} ->
            {image, [{:scale, {sx, sy}} | transforms]}

          %{type: :reset_matrix} ->
            {image, []}

          item ->
            {Sketch.Render.render_png(item, image, transforms), transforms}
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
