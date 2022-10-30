##[
cairo.nim
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
  cairo_t* = ptr object of RootObj


when defined(build_unused):
  proc gdk_cairo_create*(wnd: GdkWindowPtr
                         ): cairo_t {.importc: "gdk_cairo_create".}

  proc cairo_destroy*(src: cairo_t): void {.importc: "cairo_fill".}
  proc cairo_fill*(src: cairo_t): void {.importc: "cairo_fill".}


when isMainModule:
  type
    app_data = ptr app_data_obj
    app_data_obj = object of RootObj
      wnd: GdkWindowPtr


  proc cb_timer(user_data: gpointer): gboolean {.cdecl.} =
    ##[ failure code for draw_image.nim
    ]##
    var data = cast[app_data](user_data)
    if isNil(data):
        return gfalse

    let cr = gdk_cairo_create(data.wnd)
    cairo_fill(cr)
    cairo_destroy(cr)

