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
    bufs: array[2, seq[byte]]
    flags: array[2, bool]
    pixbuf: GdkPixbufPtr
    wgt: GtkWidgetPtr

  # pattern 0: pass app_data to thread, directly.
  # pattern 1: owner is ref object
  th_data = ref th_data_obj
  th_data_obj = object of RootObj
    data_ptr: app_data

  counter = object of RootObj
    n_min, n_max, n_sum, n_idx: int

 when false:
  var th: Thread[app_data]
 else:
  var th: Thread[th_data]
 var L: Lock


 proc render(buf: var seq[byte]): void =
    for i in 0..len(buf) - 1:
        buf[i] = byte(random.rand(255))


 proc gettime(cur: var Timespec): int =
    let (prev_n, prev) = (int64(cur.tv_sec), cur.tv_nsec)
    discard clock_gettime(CLOCK_REALTIME, cur)
    let span = (int64(cur.tv_sec) - prev_n) * 1000_000 +
               (cur.tv_nsec - prev) div 1000
    return int(span)


 proc show_counter(src: var counter, msg: string, cur: int): void =
    const init = (n_min: 0x7FFF_FFFF, n_max: 0, n_sum: 0, n_idx: 0)
    src.n_idx += 1
    if src.n_idx >= 100:
        echo(msg & $(src.n_sum / src.n_idx) &
             " (" & $src.n_min & "-" & $src.n_max & ")")
        (src.n_min, src.n_max, src.n_sum, src.n_idx) = init
    else:
        src.n_min = min(src.n_min, cur)
        src.n_max = max(src.n_max, cur)
        src.n_sum += cur


 when false:
  proc cb_timer(data: app_data): void {.thread.} =
    discard
 else:
  proc cb_timer(src: th_data): void {.thread.} =
   let data = src.data_ptr
   var
      cur: Timespec
   while true:
    if isNil(data.wgt):
        echo("count...widget is null...")
        os.sleep(500); continue
    break

   var
     n_skip = 0
     skips = counter(n_min: 0x7FFF_FFFF)
     spans = counter(n_min: 0x7FFF_FFFF)
   while true:
    acquire(L)
    let idx = data.n_buf and 1
    let f = data.flags[idx]
    release(L)

    n_skip += 1
    if f: continue
    show_counter(skips, "skiped: ", n_skip)
    n_skip = 0

    let span = gettime(cur)
    show_counter(spans, "span: ", span)

    render(data.bufs[idx])

    acquire(L)
    data.flags[idx] = true
    data.n_buf = (data.n_buf + 1) and 1
    gtk_widget_queue_draw(data.wgt)
    release(L)


 proc cb_draw(wnd: GtkWidgetPtr, context: cairo_t, user_data: gpointer
              ): gboolean {.cdecl.} =
    let data = cast[app_data](user_data)
    if isNil(data):
        return gfalse
    acquire(L)
    let idx = data.n_buf and 1
    let f = data.flags[idx]
    release(L)
    if not f:
        return gfalse

    let bytes = newGBytes(data.bufs[idx][0].addr, cint(len(data.bufs[idx])))
    let buf = gdk_pixbuf_new_from_bytes(
              bytes, GDK_COLORSPACE_RGB, gfalse, 8,
              100, 100, 300)
    gdk_cairo_set_source_pixbuf(context, buf, 0, 0)
    cairo_paint(context)

    gdk_pixbuf_unref(buf)
    g_bytes_unref(bytes)
    acquire(L)
    data.flags[idx] = false
    release(L)
    return gtrue


 proc activate(app: GtkApplicationPtr, user_data: gpointer): void {.cdecl.} =
    let window = gtk_application_window_new(app)
    gtk_window_set_title(window, "Window")
    gtk_window_set_default_size(window, 200, 200)
    gtk_widget_show_all(window)

    let data = cast[app_data](user_data)
    data.n_buf = 0
    data.wgt = window

    # make dummy data...
    data.bufs[0] = newSeq[byte](100 * 100 * 3)
    data.bufs[1] = newSeq[byte](100 * 100 * 3)

    initLock(L)
    g_signal_connect2(window, "draw", cb_draw, user_data)


 proc main(argc: int, argv: openarray[cstring]): int =
  var data = app_data_obj()
  var app = gtk_application_new("org.gtk.example", G_APPLICATION_FLAGS_NONE)
  g_signal_connect(app, "activate", activate, addr(data))

  when false:
    createThread(th, cb_timer, addr(data))
  else:
    var data_th = th_data(data_ptr: addr(data))
    createThread(th, cb_timer, data_th)
  let status = g_application_run(app, argc, argv)
  g_object_unref (app);
  return status;


 when isMainModule:
    let argc = os.paramCount()
    var argv: seq[cstring]
    for i in 1..argc:
        argv.add(os.paramStr(i))
    discard main(argc, argv)

