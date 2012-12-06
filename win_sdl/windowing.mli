(** windowing with a fold style *)

type key =
  | Left | Right | Up | Down
  | Escape
  | Char of char  (* 'a' .. 'z' *)
  | Key of string

type switch_state =
  | Pressed
  | Released

type mouse_button =
  | Mouse_button_left
  | Mouse_button_middle
  | Mouse_button_right
  | Mouse_button_x of int
  | Mouse_wheel of int

(** This function works like a [List.fold_left] which means that the application
    data is given as the parameter [init] and then passed through each callback.
    A callback get the app data as first argument and then returns with this data,
    modified or not, which will be provided to the next callback in the same way. *)
val fold :
  ?window_size:int * int ->
  ?title:string ->
  ?init_gl:(unit -> unit) ->
  init:(unit -> 'a) ->
  display:('a -> surface:Sdlvideo.surface -> t:float -> dt:float -> 'a) ->
  ?reshape:('a -> width:int -> height:int -> 'a) ->
  ?redisplay:('a -> t:float -> dt:float -> bool) ->
  ?keyboard:('a -> t:float -> key:key -> state:switch_state ->
    ctrl:bool -> alt:bool -> shift:bool -> 'a) ->
  ?mouse_moved:('a -> t:float -> id:int -> x:int -> y:int -> 'a) ->
  ?mouse:('a -> t:float -> id:int -> button:mouse_button -> state:switch_state ->
    x:int -> y:int -> 'a) ->
  ?fps:int ->
  ?continue:('a -> t:float -> bool) ->
  ?paused:('a -> bool) ->
  unit -> 'a
