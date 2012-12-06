let fps = 30  (* frames per second *)
let dt = 1.0 /. float fps  (* elapsed time between 2 frames *)

(* make n loops *)
let rec loops n f w =
  if n <= 0 then w else
    let w = f w in
    loops (n-1) f w

let move_entity (x, y) (vx, vy) dt =
  (x +. vx *. dt,
   y +. vy *. dt)

(* define which components needs moving_system *)
let moving_system_comps =
  [Comp.Position_t; Comp.Velocity_t]

let moving_system e w dt =
  let pos = Comp.get_position e in
  let vel = Comp.get_velocity e in
  let new_pos = move_entity pos vel dt in
  let e = Comp.update_position e new_pos in
  Ent.Updated e, []

let make_entity pos vel =
  let e = Ent.new_entity () in
  let e = Comp.add_position e pos in
  let e = Comp.add_velocity e vel in
  (e)

let () =
  let e1 = make_entity (2.0, 3.0) (0.1, 0.1) in
  let e2 = make_entity (5.0, 6.0) (0.1, 0.2) in
  let w = Ent.new_world () in
  let w = Ent.add_entities w [e1; e2] in
  let w, moving_system_mapper =
    Ent.add_mapper w moving_system_comps
  in
  let step w =
    Ent.world_step w
      moving_system
      moving_system_mapper
      dt
  in
  let w = loops fps step w in  (* loop for 1 second *)
  Comp.print_entities w
