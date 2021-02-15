(** Windowing *)

type view_data

type t = {
  clic : int;
  paused : bool;
  continue : bool;
  app : App.t;
  view : view_data;
}

val display :
  t ->
  area:< as_widget : [> `widget ] Gtk.obj;
         misc : < allocation : Gtk.rectangle;
                  window : [> `drawable ] Gobject.obj; .. >;
         .. > ->
  t:float -> dt:float -> t

val init_view : App.t -> t
