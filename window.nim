##[
window.nim
=================
a straight conversion for gtk+-3.0 sample.


License (MPL2)::
  Copyright (c) 2022, shimoda as kuri65536 _dot_ hot mail _dot_ com
                        ( email address: convert _dot_ to . and joint string )

  This Source Code Form is subject to the terms of the Mozilla Public License,
  v.2.0. If a copy of the MPL was not distributed with this file,
  You can obtain one at https://mozilla.org/MPL/2.0/.
]##
import gtypes


type
  GdkRectangle* = object of RootObj
    x*, y*, width*, height*: cint

  GdkWindow* = object of RootObj
  GdkWindowPtr* = ptr GdkWindow


when not defined(shrink):
  proc gdk_window_begin_paint_rect*(wnd: GdkWindowPtr,
                                    rect: ptr GdkRectangle): void {.
                                    importc: "gdk_window_begin_paint_rect".}
  proc gdk_window_end_paint*(wnd: GdkWindowPtr): void {.
                             importc: "gdk_window_end_paint".}
  proc gdk_window_invalidate_rect*(wnd: GdkWindowPtr, rect: ptr GdkRectangle,
                                   invalidate_children: gboolean): void {.
                                   importc: "gdk_window_invalidate_rect".}


when isMainModule:
  proc cb_timer(user_data: gpointer): gboolean {.cdecl.} =
    var data = cast[app_data](user_data)
    if isNil(data):
        return gfalse

    var rect = GdkRectangle(x: 0, y: 0, width: 100, height: 100)
    data.wnd.gdk_window_invalidate_rect(rect.addr, gfalse)


  proc cb_timer(user_data: gpointer): gboolean {.cdecl.} =
    var data = cast[app_data](user_data)
    if isNil(data):
        return gfalse

    var rect = GdkRectangle(x: 0, y: 0, width: 100, height: 100)
    data.wnd.gdk_window_begin_paint_rect(rect.addr)
    data.wnd.gdk_window_end_paint()


