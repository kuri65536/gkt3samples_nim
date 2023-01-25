##[
app.nim
==============
functions for basic applications.


License (MPL2)::
  Copyright (c) 2022, shimoda as kuri65536 _dot_ hot mail _dot_ com
                        ( email address: convert _dot_ to . and joint string )

  This Source Code Form is subject to the terms of the Mozilla Public License,
  v.2.0. If a copy of the MPL was not distributed with this file,
  You can obtain one at https://mozilla.org/MPL/2.0/.
]##
{.passC: gorge("pkg-config --cflags gtk+-3.0").}
{.passL: gorge("pkg-config --libs gtk+-3.0").}

import gtypes
import window


type
  GtkApplication* = object
  GtkApplicationPtr* = ptr GtkApplication

  GtkWidget* = object
  GtkWidgetPtr* = ptr GtkWidget

  GApplicationFlags* {.size: sizeof(cint), pure.} = enum
    G_APPLICATION_FLAGS_NONE = 0

  gcallback* = proc(self: gpointer, user_data: gpointer
                    ): void {.cdecl.}
  callback_app* = proc(app: GtkApplicationPtr, user_data: gpointer
                      ): void {.cdecl.}


proc gtk_application_new*(class_string: cstring, flags: GApplicationFlags
                         ): GtkApplicationPtr {.importc: "gtk_application_new".}

proc g_object_unref*(app: GtkApplicationPtr): void {.importc.}

proc g_application_run*(app: GtkApplicationPtr,
                       argc: int, argv: openarray[cstring]): int {.importc.}

proc gtk_application_window_new*(app: GtkApplicationPtr
                                ): GtkWidgetPtr {.importc.}

proc gtk_window_set_title*(src: GtkWidgetPtr, title: cstring): void {.importc.}
proc gtk_window_set_default_size*(src: GtkWidgetPtr, x, y: int): void {.importc.}

proc gtk_widget_get_window*(src: GtkWidgetPtr): GdkWindowPtr {.
                            importc: "gtk_widget_get_window".}
proc gtk_widget_show_all*(src: GtkWidgetPtr): void {.importc.}
proc gtk_widget_queue_draw*(src: GtkWidgetPtr): void {.
                            importc: "gtk_widget_queue_draw".}


proc g_signal_connect_activate*(app: GtkApplicationPtr,
                                fn: callback_app, data: gpointer,
                                closure_notify: gpointer = nil, flags: int = 0
                                ): void =
    {.emit: """g_signal_connect_data(`app`, "activate", `fn`, `data`,
                                     `closure_notify`, `flags`);""".}


when isMainModule:
 import os


 proc activate(app: GtkApplicationPtr, user_data: gpointer): void {.cdecl.} =
    let window = gtk_application_window_new(app)
    gtk_window_set_title(window, "Window")
    gtk_window_set_default_size(window, 200, 200)
    gtk_widget_show_all(window)


 proc main(argc: int, argv: openarray[cstring]): int =
  var app = gtk_application_new("org.gtk.example", G_APPLICATION_FLAGS_NONE)
  g_signal_connect_activate(app, activate, nil)
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

