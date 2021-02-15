type xy = float * float
type rgb = float * float * float

let string_of_xy (x, y) =
  Printf.sprintf "(%g, %g)" x y

let string_of_rgb (r, g, b) =
  Printf.sprintf "(%.3g, %.3g, %.3g)" r g b

(* Warning: this is GENERATED CODE *)

(** Component Management *)

(* Type of Components *)

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

(* Setters *)

let add_position e v =
  Ent.add_component e (Position_t, Position v)

let add_velocity e v =
  Ent.add_component e (Velocity_t, Velocity v)

let add_radius e v =
  Ent.add_component e (Radius_t, Radius v)

let add_color e v =
  Ent.add_component e (Color_t, Color v)

let add_points e v =
  Ent.add_component e (Points_t, Points v)

let add_expand_size e v =
  Ent.add_component e (Expand_size_t, Expand_size v)

let add_expanded_time e v =
  Ent.add_component e (Expanded_time_t, Expanded_time v)

let add_expanded_birth e v =
  Ent.add_component e (Expanded_birth_t, Expanded_birth v)

let add_is_expanded e =
  Ent.add_component e (Is_expanded_t, Is_expanded)

let add_not_expanded e =
  Ent.add_component e (Not_expanded_t, Not_expanded)

let add_expanding e =
  Ent.add_component e (Expanding_t, Expanding)

let add_expanding_finished e =
  Ent.add_component e (Expanding_finished_t, Expanding_finished)

let add_unexpanding e =
  Ent.add_component e (Unexpanding_t, Unexpanding)

(* Getters *)

let get_position e =
  match Ent.get_component e Position_t with
  | Position v -> v
  | _ -> invalid_arg "get_position"

let get_velocity e =
  match Ent.get_component e Velocity_t with
  | Velocity v -> v
  | _ -> invalid_arg "get_velocity"

let get_radius e =
  match Ent.get_component e Radius_t with
  | Radius v -> v
  | _ -> invalid_arg "get_radius"

let get_color e =
  match Ent.get_component e Color_t with
  | Color v -> v
  | _ -> invalid_arg "get_color"

let get_points e =
  match Ent.get_component e Points_t with
  | Points v -> v
  | _ -> invalid_arg "get_points"

let get_expand_size e =
  match Ent.get_component e Expand_size_t with
  | Expand_size v -> v
  | _ -> invalid_arg "get_expand_size"

let get_expanded_time e =
  match Ent.get_component e Expanded_time_t with
  | Expanded_time v -> v
  | _ -> invalid_arg "get_expanded_time"

let get_expanded_birth e =
  match Ent.get_component e Expanded_birth_t with
  | Expanded_birth v -> v
  | _ -> invalid_arg "get_expanded_birth"

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

let get_radius_opt e =
  match Ent.get_component_opt e Radius_t with
  | Some (Radius v) -> Some v
  | None -> None
  | Some _ -> invalid_arg "get_radius_opt"

let get_color_opt e =
  match Ent.get_component_opt e Color_t with
  | Some (Color v) -> Some v
  | None -> None
  | Some _ -> invalid_arg "get_color_opt"

let get_points_opt e =
  match Ent.get_component_opt e Points_t with
  | Some (Points v) -> Some v
  | None -> None
  | Some _ -> invalid_arg "get_points_opt"

let get_expand_size_opt e =
  match Ent.get_component_opt e Expand_size_t with
  | Some (Expand_size v) -> Some v
  | None -> None
  | Some _ -> invalid_arg "get_expand_size_opt"

let get_expanded_time_opt e =
  match Ent.get_component_opt e Expanded_time_t with
  | Some (Expanded_time v) -> Some v
  | None -> None
  | Some _ -> invalid_arg "get_expanded_time_opt"

let get_expanded_birth_opt e =
  match Ent.get_component_opt e Expanded_birth_t with
  | Some (Expanded_birth v) -> Some v
  | None -> None
  | Some _ -> invalid_arg "get_expanded_birth_opt"

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

let get_radius_default e default =
  match Ent.get_component_opt e Radius_t with
  | Some (Radius v) -> v
  | None -> default
  | Some _ -> invalid_arg "get_radius_default"

let get_color_default e default =
  match Ent.get_component_opt e Color_t with
  | Some (Color v) -> v
  | None -> default
  | Some _ -> invalid_arg "get_color_default"

let get_points_default e default =
  match Ent.get_component_opt e Points_t with
  | Some (Points v) -> v
  | None -> default
  | Some _ -> invalid_arg "get_points_default"

let get_expand_size_default e default =
  match Ent.get_component_opt e Expand_size_t with
  | Some (Expand_size v) -> v
  | None -> default
  | Some _ -> invalid_arg "get_expand_size_default"

let get_expanded_time_default e default =
  match Ent.get_component_opt e Expanded_time_t with
  | Some (Expanded_time v) -> v
  | None -> default
  | Some _ -> invalid_arg "get_expanded_time_default"

let get_expanded_birth_default e default =
  match Ent.get_component_opt e Expanded_birth_t with
  | Some (Expanded_birth v) -> v
  | None -> default
  | Some _ -> invalid_arg "get_expanded_birth_default"

(* Interrogators *)

let has_position e =
  Ent.has_component e Position_t

let has_velocity e =
  Ent.has_component e Velocity_t

let has_radius e =
  Ent.has_component e Radius_t

let has_color e =
  Ent.has_component e Color_t

let has_points e =
  Ent.has_component e Points_t

let has_expand_size e =
  Ent.has_component e Expand_size_t

let has_expanded_time e =
  Ent.has_component e Expanded_time_t

let has_expanded_birth e =
  Ent.has_component e Expanded_birth_t

let has_is_expanded e =
  Ent.has_component e Is_expanded_t

let has_not_expanded e =
  Ent.has_component e Not_expanded_t

let has_expanding e =
  Ent.has_component e Expanding_t

let has_expanding_finished e =
  Ent.has_component e Expanding_finished_t

let has_unexpanding e =
  Ent.has_component e Unexpanding_t

(* Removers *)

let remove_position e =
  Ent.remove_component e Position_t

let remove_velocity e =
  Ent.remove_component e Velocity_t

let remove_radius e =
  Ent.remove_component e Radius_t

let remove_color e =
  Ent.remove_component e Color_t

let remove_points e =
  Ent.remove_component e Points_t

let remove_expand_size e =
  Ent.remove_component e Expand_size_t

let remove_expanded_time e =
  Ent.remove_component e Expanded_time_t

let remove_expanded_birth e =
  Ent.remove_component e Expanded_birth_t

let remove_is_expanded e =
  Ent.remove_component e Is_expanded_t

let remove_not_expanded e =
  Ent.remove_component e Not_expanded_t

let remove_expanding e =
  Ent.remove_component e Expanding_t

let remove_expanding_finished e =
  Ent.remove_component e Expanding_finished_t

let remove_unexpanding e =
  Ent.remove_component e Unexpanding_t

(* Updaters *)

let update_position e v =
  Ent.replace_component e Position_t (Position v)

let update_velocity e v =
  Ent.replace_component e Velocity_t (Velocity v)

let update_radius e v =
  Ent.replace_component e Radius_t (Radius v)

let update_color e v =
  Ent.replace_component e Color_t (Color v)

let update_points e v =
  Ent.replace_component e Points_t (Points v)

let update_expand_size e v =
  Ent.replace_component e Expand_size_t (Expand_size v)

let update_expanded_time e v =
  Ent.replace_component e Expanded_time_t (Expanded_time v)

let update_expanded_birth e v =
  Ent.replace_component e Expanded_birth_t (Expanded_birth v)

(* Debuggers *)

let string_of_component_type = function
  | Position_t -> "Position_t"
  | Velocity_t -> "Velocity_t"
  | Radius_t -> "Radius_t"
  | Color_t -> "Color_t"
  | Points_t -> "Points_t"
  | Expand_size_t -> "Expand_size_t"
  | Expanded_time_t -> "Expanded_time_t"
  | Expanded_birth_t -> "Expanded_birth_t"
  | Is_expanded_t -> "Is_expanded_t"
  | Not_expanded_t -> "Not_expanded_t"
  | Expanding_t -> "Expanding_t"
  | Expanding_finished_t -> "Expanding_finished_t"
  | Unexpanding_t -> "Unexpanding_t"

let string_of_component = function
  | Position v -> Printf.sprintf "Position %s" (string_of_xy v)
  | Velocity v -> Printf.sprintf "Velocity %s" (string_of_xy v)
  | Radius v -> Printf.sprintf "Radius %s" (string_of_float v)
  | Color v -> Printf.sprintf "Color %s" (string_of_rgb v)
  | Points v -> Printf.sprintf "Points %s" (string_of_int v)
  | Expand_size v -> Printf.sprintf "Expand_size %s" (string_of_float v)
  | Expanded_time v -> Printf.sprintf "Expanded_time %s" (string_of_float v)
  | Expanded_birth v -> Printf.sprintf "Expanded_birth %s" (string_of_float v)
  | Is_expanded -> Printf.sprintf "Is_expanded"
  | Not_expanded -> Printf.sprintf "Not_expanded"
  | Expanding -> Printf.sprintf "Expanding"
  | Expanding_finished -> Printf.sprintf "Expanding_finished"
  | Unexpanding -> Printf.sprintf "Unexpanding"

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
