defmodule Sketch.Runner do
  @behaviour :wx_object

  def start_link(sketch) do
    :wx_object.start_link(__MODULE__, sketch, [])
  end

  ## :wx_object Calbacks
  def init(sketch) do
    wx = :wx.new()

    frame =
      :wxFrame.new(
        wx,
        :wx_const.id_any(),
        sketch.title,
        size: {sketch.width, sketch.height}
      )

    :wxWindow.connect(frame, :close_window)
    :wxWindow.connect(frame, :paint, [:callback])

    :wxFrame.show(frame)

    # dc = :wxWindowDC.new(frame)

    {frame, %{frame: frame, sketch: sketch}}
  end

  ## Callbacks
  @spec handle_sync_event(any, any, %{
          :frame => any,
          :sketch => atom | %{:background => any, optional(any) => any},
          optional(any) => any
        }) :: :ok
  def handle_sync_event(request, _ref, %{frame: frame, sketch: sketch}) do
    IO.inspect(request, label: "SYNC EVENT")
    dc = :wxPaintDC.new(frame)
    context = :wxGraphicsContext.create(dc)

    # Set Background
    bg_brush = :wxBrush.new(sketch.background)

    :wxPaintDC.setBackground(dc, bg_brush)
    :wxPaintDC.clear(dc)

    pen = :wxPen.new({255, 0, 0}, width: 2)
    :wxGraphicsContext.setPen(context, pen)

    draw_shapes(context, sketch)

    :wxPaintDC.destroy(dc)

    :ok
  end

  defp draw_shapes(context, %{order: order, primitives: primitives}) do
    order
    |> Enum.reverse()
    |> Enum.each(fn id ->
      Map.get(primitives, id) |> IO.inspect() |> Sketch.Primitives.Line.render_wx(context)
    end)
  end

  @spec handle_event(any, any) ::
          {:noreply, any} | {:stop, :normal, atom | %{:frame => any, optional(any) => any}}
  def handle_event({:wx, _, _, _, {:wxClose, :close_window}}, state) do
    :wxFrame.destroy(state.frame)
    {:stop, :normal, state}
  end

  def handle_event(event, state) do
    IO.inspect(event)
    {:noreply, state}
  end

  def handle_info(:stop, state) do
    {:stop, :normal, state}
  end

  def handle_info(message, state) do
    IO.inspect(message, label: "INFO")
    {:noreply, state}
  end

  @spec handle_call(any, any, any) ::
          {:reply, {:error, <<_::120>>}, any}
          | {:stop, :normal, %{:frame => any, optional(any) => any}}
  def handle_call(:close_window, _from, %{frame: frame} = state) do
    :wxFrame.destroy(frame)
    {:stop, :normal, state}
  end

  def handle_call(message, _from, state) do
    IO.inspect(message, label: "CALL")
    {:reply, {:error, "not implemented"}, state}
  end

  def handle_cast(:inspect, state) do
    IO.inspect(state, label: "inspect")
    {:noreply, state}
  end

  def handle_cast(message, state) do
    IO.inspect(message, label: "CAST")
    {:noreply, state}
  end

  def terminate(_reason, _state) do
    IO.puts("TERMINATING")
    :timer.sleep(200)
    :wx.destroy()
    :ok
  end
end
