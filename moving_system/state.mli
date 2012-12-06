(** Game State *)

(** {3 Vars} *)

val width : int
val height : int

(** {3 Type} *)

type t

type step_env = {
  t : float;   (** current time *)
  dt : float;  (** delta time (difference time since last world step) *)
}

(** {3 World} *)

val init_state : unit -> t

val state_step :
  t -> t:float -> dt:float -> t

(** {3 Iter} *)

val iter_items :
  (Comp.entity -> unit) -> t -> unit

(** {3 Debug} *)

val print_state : t -> unit
