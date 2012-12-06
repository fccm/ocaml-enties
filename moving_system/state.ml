(* vars *)

let width, height = (640, 480)
let f_width, f_height = (float width, float height)

let num_balls = 36

let moving_ball_radius = 10.0

let min_speed =  40.0
let max_speed = 140.0

(* types for the entity/component management *)

open Comp

type step_env = {
  t : float;   (* time, now *)
  dt : float;  (* delta time (difference time since last world step) *)
}

type t = {
  w : Comp.world;
  mapper : Comp.component_type Ent.mapper;
}

(* utils *)

let pi = 3.14159_26535_89793

let dir_mul (x, y) v =
  (x *. v,
   y *. v)

let dir_add (x, y) v =
  (x +. v,
   y +. v)

let dir_sub (x, y) v =
  (x -. v,
   y -. v)

let vec_add (x1, y1) (x2, y2) =
  (x1 +. x2,
   y1 +. y2)

let vec_sub (x1, y1) (x2, y2) =
  (x1 -. x2,
   y1 -. y2)

let neg_x (x, y) = (-. x, y)
let neg_y (x, y) = (x, -. y)

(* random initialisations *)

let rand_range a b =
  a +. (Random.float (b -. a))

let rand_dir () =
  let a = Random.float (pi *. 2.0) in
  (cos a, sin a)

let rand_pos () =
  (Random.float f_width,
   Random.float f_height)

let rand_col () =
  (Random.float 1.0,
   Random.float 1.0,
   Random.float 1.0)

let rand_speed () =
  rand_range
    min_speed
    max_speed

let rand_vel () =
  let speed = rand_speed () in
  let dir = rand_dir () in
  (dir_mul dir speed)

(* moving system *)

let bounce_l_x v (x, y) = (v +. (v -. x), y)
let bounce_l_y v (x, y) = (x, v +. (v -. y))

let bounce_h_x v (x, y) = (v -. (x -. v), y)
let bounce_h_y v (x, y) = (x, v -. (y -. v))

let bounce ((px, py) as pos) vel rad =
  let bound_left   = rad
  and bound_bottom = rad
  and bound_right  = f_width -. rad
  and bound_top    = f_height -. rad in
  if px < bound_left   then bounce_l_x bound_left   pos, neg_x vel else
  if py < bound_bottom then bounce_l_y bound_bottom pos, neg_y vel else
  if px > bound_right  then bounce_h_x bound_right  pos, neg_x vel else
  if py > bound_top    then bounce_h_y bound_top    pos, neg_y vel else
  (pos, vel)

let moving_components =
  [Position_t; Velocity_t]

let moving_system e w env =
  let pos = get_position e in
  let vel = get_velocity e in
  let rad = get_radius e in
  let move_step = dir_mul vel env.dt in
  let pos = vec_add pos move_step in
  let pos, vel = bounce pos vel rad in
  let e = update_position e pos in
  let e = update_velocity e vel in
  (Ent.Updated e, [])

(* initialise world *)

let new_ball i =
  let e = Ent.new_entity () in
  let e = add_position e (rand_pos ()) in
  let e = add_velocity e (rand_vel ()) in
  let e = add_color e (rand_col ()) in
  let e = add_radius e moving_ball_radius in
  (e)

let init_state () =
  let w = Ent.new_world () in
  let w = Ent.add_entities_init w num_balls new_ball in
  let w, mapper = Ent.add_mapper w moving_components in
  { w; mapper }

(* iter *)

let iter_items f st =
  Ent.iter_entities f st.w

(* debug *)

let print_state st =
  Comp.print_entities st.w

(* game step *)

let state_step { w; mapper } ~t ~dt =
  let w =
    Ent.world_step w
      moving_system
      mapper
      { t; dt }
  in
  { w; mapper }
