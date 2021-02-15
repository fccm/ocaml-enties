(** Game State *)

(** {3 Utils} *)

val dir_mul : float * float -> float -> float * float
val dir_add : float * float -> float -> float * float
val dir_sub : float * float -> float -> float * float
val vec_add : float * float -> float * float -> float * float
val vec_sub : float * float -> float * float -> float * float

(** {3 State} *)

type t

type step_return =
  | Continue of (t * int)
  | Done of int

val init_state :
  difficulty:float -> t

val state_step :
  t ->
  t:float -> dt:float ->
  int ->
  step_return

val iter_entities :
  (Comp.entity -> unit) -> t -> unit

val print_state : t -> unit

val user_expanded_ball : t -> Comp.xy -> float -> t

val is_expanded : Comp.entity -> bool option
