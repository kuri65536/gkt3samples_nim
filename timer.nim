##[
timer.nim
==============


License (MPL2)::
  Copyright (c) 2022, shimoda as kuri65536 _dot_ hot mail _dot_ com
                        ( email address: convert _dot_ to . and joint string )

  This Source Code Form is subject to the terms of the Mozilla Public License,
  v.2.0. If a copy of the MPL was not distributed with this file,
  You can obtain one at https://mozilla.org/MPL/2.0/.
]##
import app
import gtypes

{.passC: gorge("pkg-config --cflags gtk+-3.0").}
{.passL: gorge("pkg-config --libs gtk+-3.0").}


type
  g_priority_value* {.size: sizeof(int), pure.} = enum
    G_PRIORITY_DEFAULT = 0

  callback_timer* = proc(user_data: gpointer): gboolean {.cdecl.}
  callback_destroy* = proc(user_data: gpointer): void {.cdecl.}


proc g_timeout_add_full*(prior: g_priority_value, interval: uint,
                         fn: callback_timer, data: gpointer,
                         fn_destroy: callback_destroy
                         ): uint {.discardable, importc: "g_timeout_add_full".}


when isMainModule:
 import os


 proc timer(user_data: gpointer): gboolean {.cdecl.} =
    echo("count...")
    return gtrue


 proc activate(app: GtkApplicationPtr, user_data: gpointer): void {.cdecl.} =
    let window = gtk_application_window_new(app)
    gtk_window_set_title(window, "Window")
    gtk_window_set_default_size(window, 200, 200)
    gtk_widget_show_all(window)


 proc main(argc: int, argv: openarray[cstring]): int =
  var app = gtk_application_new("org.gtk.example", G_APPLICATION_FLAGS_NONE)
  g_signal_connect_activate(app, activate, nil)
  g_timeout_add_full(G_PRIORITY_DEFAULT, 1000, timer, nil, nil)
  let status = g_application_run(app, argc, argv)
  g_object_unref (app);
  return status;


 proc main(): void =
    let argc = os.paramCount()
    var argv: seq[cstring]
    for i in 1..argc:
        argv.add(os.paramStr(i))
    discard main(argc, argv)


 main()

