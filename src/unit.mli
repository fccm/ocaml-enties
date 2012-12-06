

(** {2 Example of unit creation} *)


(** Simple ones, each component is a parameter *)


(** {6 Unit omicron} *)

val make_omicron : int -> Comp.entity
val omicron_comps : Comp.component_type list
val is_omicron : Comp.entity -> bool
val is_omicron_strict : Comp.entity -> bool

(** {6 Unit sigma} *)

val make_sigma : int -> float -> Comp.entity
val sigma_comps : Comp.component_type list
val is_sigma : Comp.entity -> bool
val is_sigma_strict : Comp.entity -> bool

(** {6 Unit upsilon} *)

val make_upsilon : string -> char -> bool -> Comp.entity
val upsilon_comps : Comp.component_type list
val is_upsilon : Comp.entity -> bool
val is_upsilon_strict : Comp.entity -> bool

(** {6 Unit iota} *)

val make_iota : unit -> Comp.entity
val iota_comps : Comp.component_type list
val is_iota : Comp.entity -> bool
val is_iota_strict : Comp.entity -> bool

(** {6 Unit mu} *)

val make_mu : int -> Comp.entity
val mu_comps : Comp.component_type list
val is_mu : Comp.entity -> bool
val is_mu_strict : Comp.entity -> bool

(* labels for parameters *)


(** {6 Unit theta} *)

val make_theta : a:int -> Comp.entity
val theta_comps : Comp.component_type list
val is_theta : Comp.entity -> bool
val is_theta_strict : Comp.entity -> bool

(** {6 Unit omega} *)

val make_omega : a:int -> b:float -> Comp.entity
val omega_comps : Comp.component_type list
val is_omega : Comp.entity -> bool
val is_omega_strict : Comp.entity -> bool

(** components with a given value *)


(** {6 Unit aleph} *)

val make_aleph : a:int -> Comp.entity
val aleph_comps : Comp.component_type list
val is_aleph : Comp.entity -> bool
val is_aleph_strict : Comp.entity -> bool

(** {6 Unit yod} *)

val make_yod : unit -> Comp.entity
val yod_comps : Comp.component_type list
val is_yod : Comp.entity -> bool
val is_yod_strict : Comp.entity -> bool

(** optional parameters *)


(* extra () should be added as needed *)


(** {6 Unit ayin} *)

val make_ayin : ?a:int -> unit -> Comp.entity
val ayin_comps : Comp.component_type list
val is_ayin : Comp.entity -> bool
val is_ayin_strict : Comp.entity -> bool

(** {6 Unit phi} *)

val make_phi : ?a:int -> b:float -> unit -> Comp.entity
val phi_comps : Comp.component_type list
val is_phi : Comp.entity -> bool
val is_phi_strict : Comp.entity -> bool

(** {6 Unit chi} *)

val make_chi : ?a:int -> bool -> Comp.entity
val chi_comps : Comp.component_type list
val is_chi : Comp.entity -> bool
val is_chi_strict : Comp.entity -> bool

(** {6 Unit psi} *)

val make_psi : int -> ?e:bool -> unit -> Comp.entity
val psi_comps : Comp.component_type list
val is_psi : Comp.entity -> bool
val is_psi_strict : Comp.entity -> bool