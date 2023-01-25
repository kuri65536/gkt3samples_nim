##[
keys.nim
==============
functions for basic applications.


License (MPL2)::
  Copyright (c) 2022, shimoda as kuri65536 _dot_ hot mail _dot_ com
                        ( email address: convert _dot_ to . and joint string )

  This Source Code Form is subject to the terms of the Mozilla Public License,
  v.2.0. If a copy of the MPL was not distributed with this file,
  You can obtain one at https://mozilla.org/MPL/2.0/.
]##
import app
import gtypes
import window


{.passC: gorge("pkg-config --cflags gtk+-3.0").}
{.passL: gorge("pkg-config --libs gtk+-3.0").}


type
  GdkEventKeyPtr* = ptr GdkEventKey
  GdkEventKey* = object of RootObj
    # typ* {.importc.}: cint
    window* {.importc.}: GdkWindowPtr
    send_event {.importc.}: int8
    time {.importc.}: uint32
    state {.importc.}: uint32
    keyval {.importc.}: int32
    length {.importc.}: int32
    str {.importc.}: cstring
    hardware_keycode {.importc.}: uint16
    group {.importc.}: uint8
    is_modifier {.importc.}: uint32

  callback_keyevents = proc(src: GtkWidgetPtr, ev: GdkEventKeyPtr,
                            user_data: gpointer): gboolean {.cdecl.}


proc g_signal_connect_key*(wgt: GtkWidgetPtr, signal: cstring,
                        fn: callback_keyevents, data: gpointer,
                        closure_notify: gpointer = nil, flags: int = 0
                        ): void =
    {.emit: "g_signal_connect_data(`wgt`, `signal`, `fn`, `data`, `closure_notify`, `flags`);".}


when isMainModule:
  import os

  type
    keys = enum
      a
      b

    app_data = ptr app_data_obj
    app_data_obj = object of RootObj
      buttons: set[keys]
      wgt: GtkWidgetPtr

    th_data = ref th_data_obj
    th_data_obj = object of RootObj
      data_ptr: app_data

  const (wnd_width, wnd_height) = (cint(200), cint(200))


  proc cb_up(wnd: GtkWidgetPtr, ev: GdkEventKeyPtr, user_data: gpointer
             ): gboolean {.cdecl.} =
    echo("release: " & $ev.time & "-" & $ev.state & "-" & $ev.keyval)
    return gtrue


  proc cb_down(wnd: GtkWidgetPtr, ev: GdkEventKeyPtr, user_data: gpointer
               ): gboolean {.cdecl.} =
    echo("press:   " & $ev.time & "-" & $ev.state & "-" & $ev.keyval)
    return gtrue


  proc activate(app: GtkApplicationPtr, user_data: gpointer): void {.cdecl.} =
    let window = gtk_application_window_new(app)
    gtk_window_set_title(window, "Sample for keyboard events")
    gtk_window_set_default_size(window, wnd_width, wnd_height)
    gtk_widget_show_all(window)

    let data = cast[app_data](user_data)
    data.wgt = window

    g_signal_connect_key(window, "key-press-event", cb_up, user_data)
    g_signal_connect_key(window, "key-release-event", cb_down, user_data)


  proc main(argc: int, argv: openarray[cstring]): void =
    var data = app_data_obj()
    var app = gtk_application_new("org.gtk.example", G_APPLICATION_FLAGS_NONE)
    g_signal_connect(app, "activate", activate, addr(data))
    let status = g_application_run(app, argc, argv)
    g_object_unref (app);


  let argc = os.paramCount()
  var argv: seq[cstring]
  for i in 1..argc:
      argv.add(os.paramStr(i))
  main(argc, argv)

