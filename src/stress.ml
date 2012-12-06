open Ent

(* components *)

type xy = float * float

type component_type =
  | Position_t
  | Velocity_t

type component =
  | Position of xy
  | Velocity of xy

(* setters *)

let add_position e v =
  Ent.add_component e (Position_t, Position v)

let add_velocity e v =
  Ent.add_component e (Velocity_t, Velocity v)

(* getters *)

let get_position e =
  match Ent.get_component e Position_t with
  | Position v -> v
  | _ -> invalid_arg "get_position"

let get_velocity e =
  match Ent.get_component e Velocity_t with
  | Velocity v -> v
  | _ -> invalid_arg "get_velocity"

(* Updaters *)

let update_position e v =
  Ent.replace_component e Position_t (Position v)

let update_velocity e v =
  Ent.replace_component e Velocity_t (Velocity v)

(* moving system *)

let move e delta (px, py) (vx, vy) =
  let new_pos =
    (px +. (delta *. vx),
     py +. (delta *. vy))
  in
  update_position e new_pos


let movement_system e w delta =
  let pos = get_position e
  and vel = get_velocity e in
  Updated (move e delta pos vel), []


let () =
  let moving_num = 15000 in
  let static_num = 15000 in
  let empty_num  = 15000 in
  let step_num = 150 in

  let new_moving_entity _ =
    let e = new_entity () in
    let e = add_position e (20., 30.) in
    let e = add_velocity e (1.2, 0.8) in
    (e)
  in
  let new_static_entity _ =
    let e = new_entity () in
    let e = add_position e (20., 30.) in
    (e)
  in
  let new_empty_entity _ =
    let e = new_entity () in
    (e)
  in

  let make_entities n f =
    Array.to_list (Array.init n f)
  in

  let es1 = make_entities moving_num new_moving_entity in
  let es2 = make_entities static_num new_static_entity in
  let es3 = make_entities empty_num  new_empty_entity in

  let w = new_world () in

  let w = add_entities w es1 in
  let w = add_entities w es2 in
  let w = add_entities w es3 in
  (*
  ignore (es2);
  ignore (es3);
  *)

  let w, movement_system_mapper =
    add_mapper w [Position_t; Velocity_t]
  in

  let app_step w delta =
    world_step w
      movement_system_mapper
      movement_system
      delta
  in

  let delta = 0.1 in

  let t0 = Unix.gettimeofday () in

  let rec aux w i =
    if i <= 0 then w else
    let w = app_step w delta in
    aux w (pred i)
  in
  let w = aux w step_num in
  ignore (w);

  let t1 = Unix.gettimeofday () in
  let t = (t1 -. t0) in

  let step_t = (t /. float step_num) in

  Printf.printf "
    moving entities:  %d
    static entities:  %d
    empty  entities:  %d

    step iterations:  %d

    total time:       %f sec.
    time for 1 step:  %f sec.
    N steps per sec.  %f
    time / move:      %f sec.
\n"
    moving_num
    static_num
    empty_num
    step_num
    t
    step_t
    (1.0 /. step_t)
    (step_t /. float moving_num)
