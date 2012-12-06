

(** {2 Example of unit creation} *)


(** Simple ones, each component is a parameter *)


(** {6 Unit omicron} *)

let make_omicron alpha =
  let _e = Ent.new_entity () in
  let _e = Comp.add_alpha _e alpha in
  (_e)

let omicron_comps = [
  Comp.Alpha_t
]

let is_omicron e =
  Ent.has_components e omicron_comps

let is_omicron_strict e =
  Ent.components_match e omicron_comps


(** {6 Unit sigma} *)

let make_sigma alpha beta =
  let _e = Ent.new_entity () in
  let _e = Comp.add_alpha _e alpha in
  let _e = Comp.add_beta _e beta in
  (_e)

let sigma_comps = [
  Comp.Alpha_t; Comp.Beta_t
]

let is_sigma e =
  Ent.has_components e sigma_comps

let is_sigma_strict e =
  Ent.components_match e sigma_comps


(** {6 Unit upsilon} *)

let make_upsilon gamma delta epsilon =
  let _e = Ent.new_entity () in
  let _e = Comp.add_gamma _e gamma in
  let _e = Comp.add_delta _e delta in
  let _e = Comp.add_epsilon _e epsilon in
  (_e)

let upsilon_comps = [
  Comp.Gamma_t; Comp.Delta_t; Comp.Epsilon_t
]

let is_upsilon e =
  Ent.has_components e upsilon_comps

let is_upsilon_strict e =
  Ent.components_match e upsilon_comps


(** {6 Unit iota} *)

let make_iota () =
  let _e = Ent.new_entity () in
  let _e = Comp.add_zeta _e  in
  (_e)

let iota_comps = [
  Comp.Zeta_t
]

let is_iota e =
  Ent.has_components e iota_comps

let is_iota_strict e =
  Ent.components_match e iota_comps


(** {6 Unit mu} *)

let make_mu alpha =
  let _e = Ent.new_entity () in
  let _e = Comp.add_alpha _e alpha in
  let _e = Comp.add_zeta _e  in
  (_e)

let mu_comps = [
  Comp.Alpha_t; Comp.Zeta_t
]

let is_mu e =
  Ent.has_components e mu_comps

let is_mu_strict e =
  Ent.components_match e mu_comps


(* labels for parameters *)


(** {6 Unit theta} *)

let make_theta ~a =
  let _e = Ent.new_entity () in
  let _e = Comp.add_alpha _e a in
  (_e)

let theta_comps = [
  Comp.Alpha_t
]

let is_theta e =
  Ent.has_components e theta_comps

let is_theta_strict e =
  Ent.components_match e theta_comps


(** {6 Unit omega} *)

let make_omega ~a ~b =
  let _e = Ent.new_entity () in
  let _e = Comp.add_alpha _e a in
  let _e = Comp.add_beta _e b in
  (_e)

let omega_comps = [
  Comp.Alpha_t; Comp.Beta_t
]

let is_omega e =
  Ent.has_components e omega_comps

let is_omega_strict e =
  Ent.components_match e omega_comps


(** components with a given value *)


(** {6 Unit aleph} *)

let make_aleph ~a =
  let _e = Ent.new_entity () in
  let _e = Comp.add_alpha _e a in
  let _e = Comp.add_beta _e 1.0 in
  (_e)

let aleph_comps = [
  Comp.Alpha_t; Comp.Beta_t
]

let is_aleph e =
  Ent.has_components e aleph_comps

let is_aleph_strict e =
  Ent.components_match e aleph_comps


(** {6 Unit yod} *)

let make_yod () =
  let _e = Ent.new_entity () in
  let _e = Comp.add_alpha _e 8 in
  let _e = Comp.add_beta _e (Random.float 1.0) in
  (_e)

let yod_comps = [
  Comp.Alpha_t; Comp.Beta_t
]

let is_yod e =
  Ent.has_components e yod_comps

let is_yod_strict e =
  Ent.components_match e yod_comps


(** optional parameters *)


(* extra () should be added as needed *)


(** {6 Unit ayin} *)

let make_ayin ?(a=10) () =
  let _e = Ent.new_entity () in
  let _e = Comp.add_alpha _e a in
  (_e)

let ayin_comps = [
  Comp.Alpha_t
]

let is_ayin e =
  Ent.has_components e ayin_comps

let is_ayin_strict e =
  Ent.components_match e ayin_comps


(** {6 Unit phi} *)

let make_phi ?(a=0) ~b () =
  let _e = Ent.new_entity () in
  let _e = Comp.add_alpha _e a in
  let _e = Comp.add_beta _e b in
  (_e)

let phi_comps = [
  Comp.Alpha_t; Comp.Beta_t
]

let is_phi e =
  Ent.has_components e phi_comps

let is_phi_strict e =
  Ent.components_match e phi_comps


(** {6 Unit chi} *)

let make_chi ?(a=2) epsilon =
  let _e = Ent.new_entity () in
  let _e = Comp.add_alpha _e a in
  let _e = Comp.add_epsilon _e epsilon in
  (_e)

let chi_comps = [
  Comp.Alpha_t; Comp.Epsilon_t
]

let is_chi e =
  Ent.has_components e chi_comps

let is_chi_strict e =
  Ent.components_match e chi_comps


(** {6 Unit psi} *)

let make_psi alpha ?(e=true) () =
  let _e = Ent.new_entity () in
  let _e = Comp.add_alpha _e alpha in
  let _e = Comp.add_epsilon _e e in
  (_e)

let psi_comps = [
  Comp.Alpha_t; Comp.Epsilon_t
]

let is_psi e =
  Ent.has_components e psi_comps

let is_psi_strict e =
  Ent.components_match e psi_comps
