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
  gc:CL_GraphicContext.t ->
  t:float -> dt:float -> t

val init_view : App.t -> t
