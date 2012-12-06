(* Warning: this is GENERATED CODE *)

(** Component Management *)


(** {3 Type of Components} *)

type component_type =
  | Alpha_t
  | Beta_t
  | Gamma_t
  | Delta_t
  | Epsilon_t
  | Zeta_t

type component =
  | Alpha of int
  | Beta of float
  | Gamma of string
  | Delta of char
  | Epsilon of bool
  | Zeta

type entity =
  (component_type, component) Ent.entity

type world =
  (component_type, component) Ent.world


(** {3 Setters} *)

val add_alpha : entity -> int -> entity
val add_beta : entity -> float -> entity
val add_gamma : entity -> string -> entity
val add_delta : entity -> char -> entity
val add_epsilon : entity -> bool -> entity
val add_zeta : entity -> entity

(** {3 Getters} *)

val get_alpha : entity -> int
val get_beta : entity -> float
val get_gamma : entity -> string
val get_delta : entity -> char
val get_epsilon : entity -> bool

(** {3 Optional Getters} *)

val get_alpha_opt : entity -> int option
val get_beta_opt : entity -> float option
val get_gamma_opt : entity -> string option
val get_delta_opt : entity -> char option
val get_epsilon_opt : entity -> bool option

(** {3 Getters with Default} *)

val get_alpha_default : entity -> int -> int
val get_beta_default : entity -> float -> float
val get_gamma_default : entity -> string -> string
val get_delta_default : entity -> char -> char
val get_epsilon_default : entity -> bool -> bool

(** {3 Interrogators} *)

val has_alpha : entity -> bool
val has_beta : entity -> bool
val has_gamma : entity -> bool
val has_delta : entity -> bool
val has_epsilon : entity -> bool
val has_zeta : entity -> bool

(** {3 Removers} *)

val remove_alpha : entity -> entity
val remove_beta : entity -> entity
val remove_gamma : entity -> entity
val remove_delta : entity -> entity
val remove_epsilon : entity -> entity
val remove_zeta : entity -> entity

(** {3 Updaters} *)

val update_alpha : entity -> int -> entity
val update_beta : entity -> float -> entity
val update_gamma : entity -> string -> entity
val update_delta : entity -> char -> entity
val update_epsilon : entity -> bool -> entity

(** {3 Debuggers} *)

val string_of_component_type : component_type -> string

val string_of_component : component -> string


(** {3 Printers} *)

val print_entity : entity -> unit
val print_entities : world -> unit
