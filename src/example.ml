open Ent

type component_type = [
  | `position_t
  | `velocity_t
  | `dummy_t
  ]

type component = [
  | `position of float * float
  | `velocity of float * float
  | `dummy of string
  ]

let new_position pos =
  (`position_t, `position pos)

let new_velocity vel =
  (`velocity_t, `velocity vel)


let get_position e =
  match get_component e `position_t with
  | `position pos -> pos
  | _ -> invalid_arg "get_position"

let get_velocity e =
  match get_component e `velocity_t with
  | `velocity pos -> pos
  | _ -> invalid_arg "get_velocity"


let get_position_opt e =
  match get_component_opt e `position_t with
  | Some (`position pos) -> Some pos
  | None -> None
  | _ -> invalid_arg "get_position_opt"

let get_velocity_opt e =
  match get_component_opt e `velocity_t with
  | Some (`velocity pos) -> Some pos
  | None -> None
  | _ -> invalid_arg "get_velocity_opt"


let replace_position e pos =
  replace_component e `position_t (`position pos)


let movement_system_mapper =
  make_mapper [`position_t; `velocity_t]

let movement_system e w delta =
  let x, y = get_position e in
  let vx, vy = get_velocity e in
  let x = x +. vx
  and y = y +. vy in
  let e = replace_position e (x, y) in
  Updated e, []


let printer e =
  let pos = get_position_opt e in
  let id = match get_id_opt e with Some id -> string_of_int id | None -> "" in
  match pos with
  | Some (x, y) ->
      Printf.printf "# e:%s: %g %g\n%!" id x y;
  | _ ->
      Printf.printf "# e:%s: invisible\n%!" id;
;;

let () =
  let e1 = new_entity () in
  let e1 = add_component e1 (new_position (20., 30.)) in
  let e1 = add_component e1 (new_velocity (1.2, 0.8)) in

  let e2 = new_entity () in
  let e2 = add_component e2 (new_position (20., 30.)) in

  let e3 = new_entity () in

  let w = new_world () in
  let w = add_entity w e1 in
  let w = add_entity w e2 in
  let w = add_entity w e3 in

  let w =
    add_system w
      movement_system_mapper
      movement_system
  in

  let p w =
    print_endline "====================";
    iter_entities printer w;
    print_newline ();
  in

  let delta = 0.1 in
  let w = world_step w delta in p w;
  let w = world_step w delta in p w;
  let w = world_step w delta in p w;
  let w = world_step w delta in p w;
  ignore (w)
