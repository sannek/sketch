-module(wx_const).
-compile(export_all).

-include_lib("wx/include/wx.hrl").

id_any() ->
  ?wxID_ANY.

black_pen() ->
  ?wxBLACK_PEN.

transparent_brush() ->
  ?wxTRANSPARENT_BRUSH.

transparent_pen() ->
  ?wxTRANSPARENT_PEN.