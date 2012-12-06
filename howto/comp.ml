type xy = float * float

let string_of_xy (x, y) =
  Printf.sprintf "(%g, %g)" x y

(* Warning: this is GENERATED CODE *)

(** Component Management *)

(* Type of Components *)

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

(* Setters *)

let add_position e v =
  Ent.add_component e (Position_t, Position v)

let add_velocity e v =
  Ent.add_component e (Velocity_t, Velocity v)

(* Getters *)

let get_position e =
  match Ent.get_component e Position_t with
  | Position v -> v
  | _ -> invalid_arg "get_position"

let get_velocity e =
  match Ent.get_component e Velocity_t with
  | Velocity v -> v
  | _ -> invalid_arg "get_velocity"

(* Optional Getters *)

let get_position_opt e =
  match Ent.get_component_opt e Position_t with
  | Some (Position v) -> Some v
  | None -> None
  | Some _ -> invalid_arg "get_position_opt"

let get_velocity_opt e =
  match Ent.get_component_opt e Velocity_t with
  | Some (Velocity v) -> Some v
  | None -> None
  | Some _ -> invalid_arg "get_velocity_opt"

(* Getters with Default *)

let get_position_default e default =
  match Ent.get_component_opt e Position_t with
  | Some (Position v) -> v
  | None -> default
  | Some _ -> invalid_arg "get_position_default"

let get_velocity_default e default =
  match Ent.get_component_opt e Velocity_t with
  | Some (Velocity v) -> v
  | None -> default
  | Some _ -> invalid_arg "get_velocity_default"

(* Interrogators *)

let has_position e =
  Ent.has_component e Position_t

let has_velocity e =
  Ent.has_component e Velocity_t

(* Removers *)

let remove_position e =
  Ent.remove_component e Position_t

let remove_velocity e =
  Ent.remove_component e Velocity_t

(* Updaters *)

let update_position e v =
  Ent.replace_component e Position_t (Position v)

let update_velocity e v =
  Ent.replace_component e Velocity_t (Velocity v)

(* Debuggers *)

let string_of_component_type = function
  | Position_t -> "Position_t"
  | Velocity_t -> "Velocity_t"

let string_of_component = function
  | Position v -> Printf.sprintf "Position %s" (string_of_xy v)
  | Velocity v -> Printf.sprintf "Velocity %s" (string_of_xy v)

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
