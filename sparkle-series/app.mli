(** The Logic *)

type new_round_func =
  score:int -> difficulty:float -> int * float

type t = {
  state : State.t;
  score : int;
  round : int;
  difficulty : float;
  new_round : new_round_func;
}

val init_app : difficulty:float -> new_round:new_round_func -> t

val user_clic : t -> t:float -> clic:int -> pos:float * float -> t

val user_infos : t -> string

val at_exit : t -> unit

val step : t -> clic:int -> t:float -> dt:float -> t * int
