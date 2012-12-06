let rand_xy () = (1.0, 1.0)

let make_ball ~pos =
  let e = Ent.new_entity () in
  let e = Comp.add_position e pos in
  (e)

let make_moving_ball ~pos ~vel =
  let e = Ent.new_entity () in
  let e = Comp.add_position e pos in
  let e = Comp.add_velocity e vel in
  (e)

let make_falling_ball ~pos =
  let e = Ent.new_entity () in
  let e = Comp.add_position e pos in
  let e = Comp.add_velocity e (0.0, -0.2) in
  (e)

let make_random_ball () =
  let e = Ent.new_entity () in
  let e = Comp.add_position e (rand_xy ()) in
  let e = Comp.add_velocity e (rand_xy ()) in
  (e)

let make_ball_defaults ?(pos=(0.0, 0.0)) ?(vel=(0.0, 0.0)) () =
  let e = Ent.new_entity () in
  let e = Comp.add_position e pos in
  let e = Comp.add_velocity e vel in
  (e)

