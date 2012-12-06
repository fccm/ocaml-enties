(** User Input *)

val mouse :
  View.t ->
  t:float ->
  id:int ->
  button:Windowing.mouse_button ->
  state:Windowing.switch_state -> x:int -> y:int -> View.t

val keyboard :
  View.t ->
  t:float ->
  key:Windowing.key ->
  state:Windowing.switch_state ->
  ctrl:bool -> alt:bool -> shift:bool -> View.t

val paused : View.t -> bool
val continue : View.t -> t:float -> bool
