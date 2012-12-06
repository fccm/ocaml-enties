type xy = float * float

(* Warning: this is GENERATED CODE *)

(** Component Management *)


(** {3 Type of Components} *)

type component_type =
  | Position_t
  | Velocity_t

type component =
  | Position of xy
  | Velocity of xy

type entity =
  (component_type, component) Ent.entity

type world =
  (component_type, component) Ent.world


(** {3 Setters} *)

val add_position : entity -> xy -> entity
val add_velocity : entity -> xy -> entity

(** {3 Getters} *)

val get_position : entity -> xy
val get_velocity : entity -> xy

(** {3 Optional Getters} *)

val get_position_opt : entity -> xy option
val get_velocity_opt : entity -> xy option

(** {3 Getters with Default} *)

val get_position_default : entity -> xy -> xy
val get_velocity_default : entity -> xy -> xy

(** {3 Interrogators} *)

val has_position : entity -> bool
val has_velocity : entity -> bool

(** {3 Removers} *)

val remove_position : entity -> entity
val remove_velocity : entity -> entity

(** {3 Updaters} *)

val update_position : entity -> xy -> entity
val update_velocity : entity -> xy -> entity

(** {3 Debuggers} *)

val string_of_component_type : component_type -> string

val string_of_component : component -> string


(** {3 Printers} *)

val print_entity : entity -> unit
val print_entities : world -> unit
