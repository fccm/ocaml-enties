(* Warning: this is GENERATED CODE *)

(** Component Management *)

(* Type of Components *)

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

(* Setters *)

let add_alpha e v =
  Ent.add_component e (Alpha_t, Alpha v)

let add_beta e v =
  Ent.add_component e (Beta_t, Beta v)

let add_gamma e v =
  Ent.add_component e (Gamma_t, Gamma v)

let add_delta e v =
  Ent.add_component e (Delta_t, Delta v)

let add_epsilon e v =
  Ent.add_component e (Epsilon_t, Epsilon v)

let add_zeta e =
  Ent.add_component e (Zeta_t, Zeta)

(* Getters *)

let get_alpha e =
  match Ent.get_component e Alpha_t with
  | Alpha v -> v
  | _ -> invalid_arg "get_alpha"

let get_beta e =
  match Ent.get_component e Beta_t with
  | Beta v -> v
  | _ -> invalid_arg "get_beta"

let get_gamma e =
  match Ent.get_component e Gamma_t with
  | Gamma v -> v
  | _ -> invalid_arg "get_gamma"

let get_delta e =
  match Ent.get_component e Delta_t with
  | Delta v -> v
  | _ -> invalid_arg "get_delta"

let get_epsilon e =
  match Ent.get_component e Epsilon_t with
  | Epsilon v -> v
  | _ -> invalid_arg "get_epsilon"

(* Optional Getters *)

let get_alpha_opt e =
  match Ent.get_component_opt e Alpha_t with
  | Some (Alpha v) -> Some v
  | None -> None
  | Some _ -> invalid_arg "get_alpha_opt"

let get_beta_opt e =
  match Ent.get_component_opt e Beta_t with
  | Some (Beta v) -> Some v
  | None -> None
  | Some _ -> invalid_arg "get_beta_opt"

let get_gamma_opt e =
  match Ent.get_component_opt e Gamma_t with
  | Some (Gamma v) -> Some v
  | None -> None
  | Some _ -> invalid_arg "get_gamma_opt"

let get_delta_opt e =
  match Ent.get_component_opt e Delta_t with
  | Some (Delta v) -> Some v
  | None -> None
  | Some _ -> invalid_arg "get_delta_opt"

let get_epsilon_opt e =
  match Ent.get_component_opt e Epsilon_t with
  | Some (Epsilon v) -> Some v
  | None -> None
  | Some _ -> invalid_arg "get_epsilon_opt"

(* Getters with Default *)

let get_alpha_default e default =
  match Ent.get_component_opt e Alpha_t with
  | Some (Alpha v) -> v
  | None -> default
  | Some _ -> invalid_arg "get_alpha_default"

let get_beta_default e default =
  match Ent.get_component_opt e Beta_t with
  | Some (Beta v) -> v
  | None -> default
  | Some _ -> invalid_arg "get_beta_default"

let get_gamma_default e default =
  match Ent.get_component_opt e Gamma_t with
  | Some (Gamma v) -> v
  | None -> default
  | Some _ -> invalid_arg "get_gamma_default"

let get_delta_default e default =
  match Ent.get_component_opt e Delta_t with
  | Some (Delta v) -> v
  | None -> default
  | Some _ -> invalid_arg "get_delta_default"

let get_epsilon_default e default =
  match Ent.get_component_opt e Epsilon_t with
  | Some (Epsilon v) -> v
  | None -> default
  | Some _ -> invalid_arg "get_epsilon_default"

(* Interrogators *)

let has_alpha e =
  Ent.has_component e Alpha_t

let has_beta e =
  Ent.has_component e Beta_t

let has_gamma e =
  Ent.has_component e Gamma_t

let has_delta e =
  Ent.has_component e Delta_t

let has_epsilon e =
  Ent.has_component e Epsilon_t

let has_zeta e =
  Ent.has_component e Zeta_t

(* Removers *)

let remove_alpha e =
  Ent.remove_component e Alpha_t

let remove_beta e =
  Ent.remove_component e Beta_t

let remove_gamma e =
  Ent.remove_component e Gamma_t

let remove_delta e =
  Ent.remove_component e Delta_t

let remove_epsilon e =
  Ent.remove_component e Epsilon_t

let remove_zeta e =
  Ent.remove_component e Zeta_t

(* Updaters *)

let update_alpha e v =
  Ent.replace_component e Alpha_t (Alpha v)

let update_beta e v =
  Ent.replace_component e Beta_t (Beta v)

let update_gamma e v =
  Ent.replace_component e Gamma_t (Gamma v)

let update_delta e v =
  Ent.replace_component e Delta_t (Delta v)

let update_epsilon e v =
  Ent.replace_component e Epsilon_t (Epsilon v)

(* Debuggers *)

let string_of_component_type = function
  | Alpha_t -> "Alpha_t"
  | Beta_t -> "Beta_t"
  | Gamma_t -> "Gamma_t"
  | Delta_t -> "Delta_t"
  | Epsilon_t -> "Epsilon_t"
  | Zeta_t -> "Zeta_t"

let string_of_component = function
  | Alpha v -> Printf.sprintf "Alpha %s" (string_of_int v)
  | Beta v -> Printf.sprintf "Beta %s" (string_of_float v)
  | Gamma v -> Printf.sprintf "Gamma %s" (v)
  | Delta v -> Printf.sprintf "Delta %s" (String.make 1 v)
  | Epsilon v -> Printf.sprintf "Epsilon %s" (string_of_bool v)
  | Zeta -> Printf.sprintf "Zeta"

(* Printers *)


let _print_entity e =
  Printf.printf "Entity:
";
  Ent.iter_components e (fun comp_t comp ->
    Printf.printf "  %s  %s
"
      (string_of_component_type comp_t)
      (string_of_component comp)
  );
  Printf.printf "
"

let print_entity e =
  _print_entity e;
  Printf.printf "%!"

let print_entities w =
  Ent.iter_entities _print_entity w;
  Printf.printf "====================
";
  Printf.printf "%!"
