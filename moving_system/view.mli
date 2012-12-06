(** View *)

(** {3 App Data} *)

type app_data

val init_app_data : State.t -> app_data

(** {3 Functional Callbacks} *)

val display :
  app_data -> win:SFRenderWindow.t ->
  t:float -> dt:float ->
  app_data

val keyboard :
  app_data ->
  t:float ->
  key:Windowing.key ->
  state:Windowing.switch_state ->
  ctrl:bool -> alt:bool -> shift:bool ->
  app_data

val mouse :
  app_data ->
  t:float -> id:int ->
  button:Windowing.mouse_button ->
  state:Windowing.switch_state ->
  x:int -> y:int ->
  app_data

val paused : app_data -> bool
val continue : app_data -> t:float -> bool
