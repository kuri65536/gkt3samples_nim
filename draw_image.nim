##[
draw_image.nim
=================
a straight conversion for gtk+-3.0 sample.


License (MPL2)::
  Copyright (c) 2022, shimoda as kuri65536 _dot_ hot mail _dot_ com
                        ( email address: convert _dot_ to . and joint string )

  This Source Code Form is subject to the terms of the Mozilla Public License,
  v.2.0. If a copy of the MPL was not distributed with this file,
  You can obtain one at https://mozilla.org/MPL/2.0/.
]##
import os

import app
import timer

{.passC: gorge("pkg-config --cflags gtk+-3.0").}
{.passL: gorge("pkg-config --libs gtk+-3.0").}


type
  gdk_colorspace_value* {.size: sizeof(cint), pure.} = enum
    GDK_COLORSPACE_RGB

  GdkPixbuf* = object of RootObj
  GdkPixbufPtr* = ptr GdkPixbuf


proc gdk_pixbuf_new_from_data*(src: openarray[byte],
                               colorspace: gdk_colorspace_value,
                               has_alpha: bool,
                               bits_per_sample, width, height, rowstride: int,
                               fn_destroy: callback_destroy,
                               fn_destroy_data: callback_destroy
                               ): GdkPixbufPtr {.
                                  importc: "gdk_pixbuf_new_from_data".}
proc gdk_pixbuf_unref*(src: GdkPixbufPtr): void {.importc: "gdk_pixbuf_unref".}


when isMainModule:
 type
  app_data = ptr app_data_obj
  app_data_obj = object of RootObj
    n_buf: int
    bufs: array[2, seq[byte]]


 proc cb_timer(user_data: gpointer): bool {.cdecl.} =
    var data = cast[app_data](user_data)

    let buf = gdk_pixbuf_new_from_data(
              data.bufs[data.n_buf], GDK_COLORSPACE_RGB, false, 8,
              200, 200, 0, nil, nil)
    echo("count..." & $data.n_buf)
    gdk_pixbuf_unref(buf)
    return true


 proc activate(app: GtkApplicationPtr, user_data: gpointer): void {.cdecl.} =
    let window = gtk_application_window_new(app)
    gtk_window_set_title(window, "Window")
    gtk_window_set_default_size(window, 200, 200)
    gtk_widget_show_all(window)
    var data = cast[app_data](user_data)
    data.n_buf = 0
    data.bufs[0] = newSeq[byte](200 * 200 * 3)
    data.bufs[1] = newSeq[byte](200 * 200 * 3)


 proc main(argc: int, argv: openarray[cstring]): int =
  var data = app_data_obj()
  var app = gtk_application_new("org.gtk.example", G_APPLICATION_FLAGS_NONE)
  g_signal_connect(app, "activate", activate, addr(data))
  g_timeout_add_full(G_PRIORITY_DEFAULT, 1000, cb_timer, addr(data), nil)
  let status = g_application_run(app, argc, argv)
  g_object_unref (app);
  return status;


 when isMainModule:
    let argc = os.paramCount()
    var argv: seq[cstring]
    for i in 1..argc:
        argv.add(os.paramStr(i))
    discard main(argc, argv)

