defprotocol Sketch.Render do
  @doc """
    Called to render this item to screen (using `wxWidgets`).
    The return type does not matter.

    You only need to implement this if you want to extend
    `Sketch` with custom items.

    Arguments
    * `item` - whatever was added to the items in the sketch.
    Usually a map or a struct containing the information needed to render it, like coordinates etc.
    * `context` - the current `wxGraphicsContext`

    See the [wx docs](https://erlang.org/doc/man/wxGraphicsContext.html) for more details on `wxGraphicsContext`
    and the available functions
  """
  def render_wx(item, context)

  @doc """
    Called to render this item to PNG (using `Mogrify`).
    Must return a `%Mogrify.Image{}` struct.

    You only need to implement this if you want to extend
    `Sketch` with custom items.

    Arguments
    * `item` - whatever was added to the items in the sketch.
    Usually a map or a struct containing the information needed to render it, like coordinates etc.
    * `image` - The `Mogrify.Image` struct containing all operations so far.
    * `transforms` - keyword list of all transformations applied to this item.

    It is recommended to use `Sketch.Render.Png.build_transform_opts/1` to get the correct transformation
    commands.

    See the [Mogrify](https://hexdocs.pm/mogrify/readme.html) and [ImageMagick](https://legacy.imagemagick.org/Usage/draw/)
  """
  @spec render_png(any, Mogrify.Image.t(), list) :: Mogrify.Image.t()
  def render_png(item, image, transforms)

  @doc """
    Called to render this item to SVG.
    Must return an :xmerl.export_simple/2 compatible 'Content' parameter (e.g. a list of XML nodes).

    Arguments
    * `item` - whatever was added to the items in the sketch.
    Usually a map or a struct containing the information needed to render it, like coordinates etc.
  """
  @spec render_svg(any) :: any
  def render_svg(item)
end
