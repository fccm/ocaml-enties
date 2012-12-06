type xy = float * float
type rgb = float * float * float

(* Warning: this is GENERATED CODE *)

(** Component Management *)


(** {3 Type of Components} *)

type component_type =
  | Position_t
  | Velocity_t
  | Radius_t
  | Color_t
  | Points_t
  | Expand_size_t
  | Expanded_time_t
  | Expanded_birth_t
  | Is_expanded_t
  | Not_expanded_t
  | Expanding_t
  | Expanding_finished_t
  | Unexpanding_t

type component =
  | Position of xy
  | Velocity of xy
  | Radius of float
  | Color of rgb
  | Points of int
  | Expand_size of float
  | Expanded_time of float
  | Expanded_birth of float
  | Is_expanded
  | Not_expanded
  | Expanding
  | Expanding_finished
  | Unexpanding

type entity =
  (component_type, component) Ent.entity

type world =
  (component_type, component) Ent.world


(** {3 Setters} *)

val add_position : entity -> xy -> entity
val add_velocity : entity -> xy -> entity
val add_radius : entity -> float -> entity
val add_color : entity -> rgb -> entity
val add_points : entity -> int -> entity
val add_expand_size : entity -> float -> entity
val add_expanded_time : entity -> float -> entity
val add_expanded_birth : entity -> float -> entity
val add_is_expanded : entity -> entity
val add_not_expanded : entity -> entity
val add_expanding : entity -> entity
val add_expanding_finished : entity -> entity
val add_unexpanding : entity -> entity

(** {3 Getters} *)

val get_position : entity -> xy
val get_velocity : entity -> xy
val get_radius : entity -> float
val get_color : entity -> rgb
val get_points : entity -> int
val get_expand_size : entity -> float
val get_expanded_time : entity -> float
val get_expanded_birth : entity -> float

(** {3 Optional Getters} *)

val get_position_opt : entity -> xy option
val get_velocity_opt : entity -> xy option
val get_radius_opt : entity -> float option
val get_color_opt : entity -> rgb option
val get_points_opt : entity -> int option
val get_expand_size_opt : entity -> float option
val get_expanded_time_opt : entity -> float option
val get_expanded_birth_opt : entity -> float option

(** {3 Getters with Default} *)

val get_position_default : entity -> xy -> xy
val get_velocity_default : entity -> xy -> xy
val get_radius_default : entity -> float -> float
val get_color_default : entity -> rgb -> rgb
val get_points_default : entity -> int -> int
val get_expand_size_default : entity -> float -> float
val get_expanded_time_default : entity -> float -> float
val get_expanded_birth_default : entity -> float -> float

(** {3 Interrogators} *)

val has_position : entity -> bool
val has_velocity : entity -> bool
val has_radius : entity -> bool
val has_color : entity -> bool
val has_points : entity -> bool
val has_expand_size : entity -> bool
val has_expanded_time : entity -> bool
val has_expanded_birth : entity -> bool
val has_is_expanded : entity -> bool
val has_not_expanded : entity -> bool
val has_expanding : entity -> bool
val has_expanding_finished : entity -> bool
val has_unexpanding : entity -> bool

(** {3 Removers} *)

val remove_position : entity -> entity
val remove_velocity : entity -> entity
val remove_radius : entity -> entity
val remove_color : entity -> entity
val remove_points : entity -> entity
val remove_expand_size : entity -> entity
val remove_expanded_time : entity -> entity
val remove_expanded_birth : entity -> entity
val remove_is_expanded : entity -> entity
val remove_not_expanded : entity -> entity
val remove_expanding : entity -> entity
val remove_expanding_finished : entity -> entity
val remove_unexpanding : entity -> entity

(** {3 Updaters} *)

val update_position : entity -> xy -> entity
val update_velocity : entity -> xy -> entity
val update_radius : entity -> float -> entity
val update_color : entity -> rgb -> entity
val update_points : entity -> int -> entity
val update_expand_size : entity -> float -> entity
val update_expanded_time : entity -> float -> entity
val update_expanded_birth : entity -> float -> entity

(** {3 Debuggers} *)

val string_of_component_type : component_type -> string

val string_of_component : component -> string


(** {3 Printers} *)

val print_entity : entity -> unit
val print_entities : world -> unit
