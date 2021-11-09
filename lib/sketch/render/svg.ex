defmodule Sketch.Render.Svg do
  def render_to_string(sketch, opts \\ []) do
    sketch
    |> do_render()
    |> add_svg_elem(sketch)
    |> :xmerl.export_simple(:xmerl_xml)
    |> IO.chardata_to_string()
  end

  defmodule Paint do
    defstruct fill: nil, stroke: nil, stroke_weight: 1
  end

  def do_render(sketch) do
    {nodes, _transforms, _paint} =
      Enum.reverse(sketch.order)
      |> Enum.reduce({[], [], %Paint{}}, fn id, {nodes, transforms, paint} ->
        case Map.get(sketch.items, id) do
          %{type: :fill, color: color} ->
            {nodes, transforms, %Paint{paint | fill: Sketch.Color.to_hex(color)}}

          %{type: :no_fill} ->
            {nodes, transforms, %Paint{paint | fill: nil}}

          %{type: :stroke, color: color} ->
            {nodes, transforms, %Paint{paint | stroke: Sketch.Color.to_hex(color)}}

          %{type: :stroke_weight, weight: weight} ->
            {nodes, transforms, %Paint{paint | stroke_weight: weight}}

          %{type: :no_stroke} ->
            {nodes, transforms, %Paint{paint | stroke: nil}}

          %{type: :translate, dx: dx, dy: dy} ->
            {nodes, ["translate(#{dx} #{dy})" | transforms], paint}

          %{type: :rotate, angle: angle} ->
            {nodes, ["rotate(#{angle})" | transforms], paint}

          %{type: :scale, sx: sx, sy: sy} ->
            {nodes, ["scale(#{sx} #{sy})" | transforms], paint}

          %{type: :reset_matrix} ->
            {nodes, [], paint}

          item ->
            elem =
              Sketch.Render.render_svg(item)
              |> transform_and_paint(transforms, paint)

            {[elem | nodes], transforms, paint}
        end
      end)

    nodes |> IO.inspect(label: "nn")
  end

  defp add_svg_elem(children, sketch) do
    [
      {:svg,
       [
         xmlns: "http://www.w3.org/2000/svg",
         viewbox: "0 0 #{sketch.width} #{sketch.height}",
         width: sketch.width,
         height: sketch.height
       ], children}
    ]
  end

  defp transform_and_paint(element, transforms, paint) do
    attrs = [transforms_attr(transforms), paint_attrs(paint)] |> List.flatten()

    case attrs do
      [] -> element
      _ -> {:g, attrs, [element]}
    end
  end

  defp transforms_attr([]), do: []
  defp transforms_attr(transforms), do: {:transform, Enum.join(transforms, " ")}

  defp paint_attrs(paint) do
    [{:fill, paint.fill}, {:stroke, paint.stroke}, {:"stroke-width", paint.stroke_weight}]
    |> Enum.reject(&(elem(&1, 1) == nil))
  end
end
