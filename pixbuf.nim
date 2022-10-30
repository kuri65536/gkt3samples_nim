##[
pixbuf.nim
=================
a straight conversion for gtk+-3.0 sample.


License (MPL2)::
  Copyright (c) 2022, shimoda as kuri65536 _dot_ hot mail _dot_ com
                        ( email address: convert _dot_ to . and joint string )

  This Source Code Form is subject to the terms of the Mozilla Public License,
  v.2.0. If a copy of the MPL was not distributed with this file,
  You can obtain one at https://mozilla.org/MPL/2.0/.
]##
import window


type
  GdkPixbuf* = object of RootObj
  GdkPixbufPtr* = ptr GdkPixbuf


when not defined(shrink_unused):
  proc gdk_pixbuf_copy_area*(src: GdkPixbufPtr,
                             src_x, src_y, src_width, src_height: int,
                             dest: GdkPixbufPtr, dest_x, dest_y: int
                             ): void {.importc: "gdk_pixbuf_copy_area".}

  proc gdk_pixbuf_get_from_window*(wnd: GdkWindowPtr, x, y, width, height: int
                                   ): GdkPixbufPtr {.
                                    importc: "gdk_pixbuf_get_from_window".}


when isMainModule:


 proc cb_timer(user_data: gpointer): gboolean {.cdecl.} =
    var data = cast[app_data](user_data)
    if isNil(data):
        return gtrue

    buf.gdk_pixbuf_copy_area(0, 0, 100, 100, data.pixbuf, 0, 0)

