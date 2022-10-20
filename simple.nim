##[
simple.c
==============
a straight conversion for gtk+-3.0 sample.


License (MPL2)::
  Copyright (c) 2022, shimoda as kuri65536 _dot_ hot mail _dot_ com
                        ( email address: convert _dot_ to . and joint string )

  This Source Code Form is subject to the terms of the Mozilla Public License,
  v.2.0. If a copy of the MPL was not distributed with this file,
  You can obtain one at https://mozilla.org/MPL/2.0/.
]##
{.passC: gorge("pkg-config --cflags gtk+-3.0").}
{.passL: gorge("pkg-config --libs gtk+-3.0").}


type
  GtkApplication = object
  GtkApplicationPtr = ptr GtkApplication

  GApplicationFlags {.size: sizeof(cint), pure.} = enum
    G_APPLICATION_FLAGS_NONE = 0


proc gtk_application_new(class_string: cstring, flags: GApplicationFlags
                         ): GtkApplicationPtr {.importc: "gtk_application_new".}

proc g_object_unref(app: GtkApplicationPtr): void {.importc.}

proc g_application_run(app: GtkApplicationPtr,
                       argc: int, argv: openarray[cstring]): int {.importc.}

#[

static void
activate (GtkApplication* app,
          gpointer        user_data)
{
  GtkWidget *window;

  window = gtk_application_window_new (app);
  gtk_window_set_title (GTK_WINDOW (window), "Window");
  gtk_window_set_default_size (GTK_WINDOW (window), 200, 200);
  gtk_widget_show_all (window);
]#


proc main(argc: int, argv: openarray[cstring]): int =
  var app = gtk_application_new("org.gtk.example", G_APPLICATION_FLAGS_NONE)
  #[
  g_signal_connect (app, "activate", G_CALLBACK (activate), NULL);
  ]#
  let status = g_application_run(app, argc, argv)
  g_object_unref (app);
  return status;


when isMainModule:
    discard main(0, [])

