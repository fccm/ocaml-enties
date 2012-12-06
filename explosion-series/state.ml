
let width, height = Vars.window_size
let f_width, f_height = (float width, float height)

let num_balls = 24

let moving_balls_radius = 8.0

let min_radius = 6.0
let max_radius = 12.0

let min_expand_size = moving_balls_radius *.  2.0
let max_expand_size = moving_balls_radius *. 10.0

let min_expanded_time =  4.0
let max_expanded_time = 20.0

let expand_speed = 68.0

let user_init_radius = 1.0
let user_expand_size = moving_balls_radius *. 6.0
let user_expanded_time = 8.0

(* types for the entity/component management *)

type circle_collision_shape = (float * float) * float  (* center, radius *)

type step_env = {
  t : float;   (* time, now *)
  dt : float;  (* delta time (difference time since last step *)
  expanded : circle_collision_shape list;
}

open Comp

type t = {
  w : Comp.world;
}

let is_expanded e =
  let is = has_is_expanded e
  and is_not = has_not_expanded e in
  match is, is_not with
  | true, false -> Some true
  | false, true -> Some false
  | false, false -> None
  | true, true -> assert false

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

let neg_x (x, y) =
  (-. x, y)

let neg_y (x, y) =
  (x, -. y)

(* random initialisations *)

let rand_range a b =
  a +. (Random.float (b -. a))

let rand_dir () =
  let a = Random.float (pi *. 2.0) in
  (cos a, sin a)

let rand_pos () =
  (Random.float f_width,
   Random.float f_height)

let rand_color () =
  (0.25 +. Random.float 0.75,
   0.25 +. Random.float 0.75,
   0.25 +. Random.float 0.75)

let white = (1.0, 1.0, 1.0)
let dark = (0.1, 0.1, 0.1)

let rand_points () =
  10 * (Random.int 1000)

let min_speed =  40.0
let max_speed = 100.0

let rand_speed () =
  rand_range
    min_speed
    max_speed

let rand_vel () =
  let speed = rand_speed () in
  let dir = rand_dir () in
  (dir_mul dir speed)

let rand_radius () =
  rand_range
    min_radius
    max_radius

let rand_expand_size () =
  rand_range
    min_expand_size
    max_expand_size

let rand_expanded_time () =
  rand_range
    min_expanded_time
    max_expanded_time

(* moving system *)

let bounce_l_x v (x, y) = (v +. (v -. x), y)
let bounce_l_y v (x, y) = (x, v +. (v -. y))

let bounce_h_x v (x, y) = (v -. (x -. v), y)
let bounce_h_y v (x, y) = (x, v -. (y -. v))

let bounce ((px, py) as pos) ((vx, vy) as vel) rad =
  let bound_left   = rad
  and bound_bottom = rad
  and bound_right  = f_width -. rad
  and bound_top    = f_height -. rad in
  if px < bound_left   then bounce_l_x bound_left   pos, neg_x vel else
  if py < bound_bottom then bounce_l_y bound_bottom pos, neg_y vel else
  if px > bound_right  then bounce_h_x bound_right  pos, neg_x vel else
  if py > bound_top    then bounce_h_y bound_top    pos, neg_y vel else
  (pos, vel)

let moving_components = [Position_t; Velocity_t]

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

(* collision system *)

let length x y =
  sqrt (x *. x +. y *. y)

let collide ((x1, y1), radius1) ((x2, y2), radius2) =
  let x = x1 -. x2
  and y = y1 -. y2 in
  (length x y) < (radius1 +. radius2)

let collision_shape e =
  let pos = get_position e in
  let rad = get_radius e in
  (pos, rad)

let expand e t =
  let e = remove_velocity e in
  let e = remove_not_expanded e in
  let e = add_is_expanded e in
  let e = add_expanding e in
  let e = add_expanded_birth e t in
  (e)

let push_points e score =
  score + (get_points e)

let collision_components = [Not_expanded_t]

let collision_system e w env score =
  let coll = collision_shape e in
  let collided = List.exists (collide coll) env.expanded in
  if collided
  then Ent.Updated (expand e env.t), [], (push_points e score)
  else Ent.Identical, [], (score)

(* expanding system *)

let stop_expanding e =
  let size = get_expand_size e in
  let e = update_radius e size in
  let e = remove_expand_size e in
  let e = remove_expanding e in
  let e = add_expanding_finished e in
  (e)

let expanding e dt =
  let rad = get_radius e in
  let rad = rad +. (expand_speed *. dt) in
  let e = update_radius e rad in
  (e)

let expanding_components = [Expanding_t]

let expanding_system e w env =
  let exp_size = get_expand_size e in
  let expanded = expanding e env.dt in
  let radius = get_radius expanded in
  if radius < exp_size
  then Ent.Updated (expanded), []
  else Ent.Updated (stop_expanding e), []

(* unexpanding system *)

let unexpanding e dt =
  let rad = get_radius e in
  let rad = rad -. (8.0 *. dt) in
  let e = update_radius e rad in
  (e)

let unexpanding_components = [Unexpanding_t]

let unexpanding_system e w env =
  let unexpanded = unexpanding e env.dt in
  let radius = get_radius unexpanded in
  if radius > epsilon_float
  then Ent.Updated (unexpanded), []
  else Ent.Removed, []

(* fade out expanded balls *)

let todo_unexpand e =
  let e = remove_expanding e in
  let e = add_unexpanding e in
  (e)

let fadeout_components = [Is_expanded_t]

let fadeout_system e w env =
  if has_unexpanding e
  then Ent.Identical, []
  else begin
    let te = get_expanded_time e in
    let tb = get_expanded_birth e in
    if env.t < (tb +. te)
    then Ent.Identical, []
    else Ent.Updated (todo_unexpand e), []
  end

(* all systems *)

let systems = [
    (moving_components, moving_system);
    (expanding_components, expanding_system);
    (unexpanding_components, unexpanding_system);
    (fadeout_components, fadeout_system);
  ]

let foldable_systems = [
    (collision_components, collision_system);
  ]

(* initialise world *)

let make_ball diff =
  let opp_diff = 1.0 -. diff in
  ignore (opp_diff);
  let e = Ent.new_entity () in
  let e = add_position e (rand_pos ()) in
  let e = add_velocity e (rand_vel ()) in
  let e = add_color e (rand_color ()) in
  (*
  let e = add_radius e moving_balls_radius in
  *)
  let e = add_radius e (rand_radius ()) in
  let e = add_expand_size e (rand_expand_size ()) in
  let e = add_expanded_time e (rand_expanded_time ()) in
  let e = add_points e (rand_points ()) in
  let e = add_not_expanded e in
  (e)

let ball_become_bad e diff =
  let points = float (get_points e) in
  let points = -. (points *. diff) in
  let e = update_points e (truncate points) in
  let e = update_color e dark in
  (e)

let new_ball diff i =
  let bad_prob = diff /. 2.0 in
  let e = make_ball diff in
  if Random.float 1.0 > bad_prob then e
  else ball_become_bad e diff

let init_state ~difficulty:diff =
  let w = Ent.new_world () in
  let w = Ent.add_entities_init w num_balls (new_ball diff) in
  { w }

(* game step *)

type step_return =
  | Continue of (t * int)
  | Done of int

let get_expanded_balls w =
  Ent.fold_entities
    (fun e acc ->
      if has_is_expanded e
      then ((collision_shape e) :: acc)
      else (acc)
    ) w []

let state_step { w } ~t ~dt score =
  let expanded = get_expanded_balls w in
  let w =
    List.fold_left
      (fun w (components, system) ->
        let w, mapper = Ent.add_mapper w components in
        Ent.world_step w system mapper { t; dt; expanded }
      ) w systems
  in
  let w, score =
    List.fold_left
      (fun (w, score) (components, system) ->
        let w, mapper = Ent.add_mapper w components in
        Ent.world_step_fold w system mapper { t; dt; expanded } score
      )
      (w, score)
      foldable_systems
  in
  let n = Ent.num_entities w in
  if n = 0 then Done score else Continue ({ w }, score)

let state_step st ~t ~dt score =
  try state_step st ~t ~dt score
  with e ->
    Comp.print_entities st.w;
    raise e

(* iter / print *)

let iter_entities f st =
  Ent.iter_entities f st.w

let print_state st =
  Comp.print_entities st.w

(* user interactions *)

let make_user_expanded_ball pos t =
  let e = Ent.new_entity () in
  let e = add_position e pos in
  let e = add_color e white in
  let e = add_radius e user_init_radius in
  let e = add_expand_size e user_expand_size in
  let e = add_expanded_time e user_expanded_time in
  let e = add_expanded_birth e t in
  let e = add_expanding e in
  let e = add_is_expanded e in
  (e)

let user_expanded_ball st pos t =
  let e = make_user_expanded_ball pos t in
  let w = Ent.add_entity st.w e in
  { w }
