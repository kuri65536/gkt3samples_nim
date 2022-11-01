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
import cairo
import gtypes
import pixbuf
import window

{.passC: gorge("pkg-config --cflags gtk+-3.0").}
{.passL: gorge("pkg-config --libs gtk+-3.0").}


type
  gdk_colorspace_value* {.size: sizeof(cint), pure.} = enum
    GDK_COLORSPACE_RGB = 0


proc gdk_pixbuf_new_from_bytes*(src: GBytes,
                                colorspace: gdk_colorspace_value,
                                has_alpha: gboolean,
                                bits_per_sample, width, height, rowstride: cint,
                                ): GdkPixbufPtr {.
                                  importc: "gdk_pixbuf_new_from_bytes".}
proc gdk_pixbuf_unref*(src: GdkPixbufPtr): void {.importc: "gdk_pixbuf_unref".}


when isMainModule:
 import posix
 import random
 import std/locks

 type
  app_data = ptr app_data_obj
  app_data_obj = object of RootObj
    n_buf: int
    f_update: bool
    bufs: array[2, GBytes]
    pixbuf: GdkPixbufPtr
    wgt: GtkWidgetPtr

 var th: Thread[app_data]
 var L: Lock


 proc render(buf: var seq[byte]): void =
    for i in 0..len(buf) - 1:
        buf[i] = byte(random.rand(255))


 proc cb_timer(data: app_data): void {.thread.} =
   var
      cur: Timespec
   while true:
    if isNil(data.wgt):
        echo("count...widget is null...")
        os.sleep(500); continue
    acquire(L)
    let f = data.f_update
    release(L)
    if f:
        continue

    data.n_buf += 1
    let (prev_n, prev) = (int64(cur.tv_sec), cur.tv_nsec)
    discard clock_gettime(CLOCK_REALTIME, cur)
    let span = (int64(cur.tv_sec) - prev_n) * 1000_000 +
               (cur.tv_nsec - prev) div 1000
    echo("timer..." & $prev_n & "=>" & $span)

    let idx = data.n_buf and 1
    g_bytes_unref(data.bufs[idx])

    var src = newSeq[byte](100 * 100 * 3)
    render(src)
    let bytes = newGBytes(src[0].addr, 100 * 100 * 3)
    data.bufs[idx] = bytes

    acquire(L)
    data.f_update = true
    gtk_widget_queue_draw(data.wgt)
    release(L)


 proc cb_draw(wnd: GtkWidgetPtr, context: cairo_t, user_data: gpointer
              ): gboolean {.cdecl.} =
    let data = cast[app_data](user_data)
    if isNil(data):
        return gfalse
    acquire(L)
    let f = data.f_update
    release(L)
    if not f:
        return gfalse

    let idx = data.n_buf and 1
    let buf = gdk_pixbuf_new_from_bytes(
              data.bufs[idx], GDK_COLORSPACE_RGB, gfalse, 8,
              100, 100, 300)
    gdk_cairo_set_source_pixbuf(context, buf, 0, 0)
    cairo_paint(context)

    gdk_pixbuf_unref(buf)
    acquire(L)
    data.f_update = false
    release(L)
    return gtrue


 proc activate(app: GtkApplicationPtr, user_data: gpointer): void {.cdecl.} =
    let window = gtk_application_window_new(app)
    gtk_window_set_title(window, "Window")
    gtk_window_set_default_size(window, 200, 200)
    gtk_widget_show_all(window)

    let wnd = gtk_widget_get_window(window)
    let data = cast[app_data](user_data)
    data.f_update = false
    data.n_buf = 0
    data.wgt = window

    # make dummy data...
    var src = newSeq[byte](1)
    data.bufs[0] = newGBytes(src[0].addr, 1)
    data.bufs[1] = newGBytes(src[0].addr, 1)

    initLock(L)
    g_signal_connect2(window, "draw", cb_draw, user_data)


 proc main(argc: int, argv: openarray[cstring]): int =
  var data = app_data_obj()
  var app = gtk_application_new("org.gtk.example", G_APPLICATION_FLAGS_NONE)
  g_signal_connect(app, "activate", activate, addr(data))
  createThread(th, cb_timer, addr(data))
  let status = g_application_run(app, argc, argv)
  g_object_unref (app);
  return status;


 when isMainModule:
    let argc = os.paramCount()
    var argv: seq[cstring]
    for i in 1..argc:
        argv.add(os.paramStr(i))
    discard main(argc, argv)

