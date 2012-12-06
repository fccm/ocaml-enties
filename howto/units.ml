open Units_funcs

let make_my_item position velocity =
  let e = Ent.new_entity () in
  let e = Comp.add_position e position in
  let e = Comp.add_velocity e velocity in
  (e)

let make_item ~pos =
  let e = Ent.new_entity () in
  let e = Comp.add_position e pos in
  (e)

let make_moving_item ~pos ~vel =
  let e = Ent.new_entity () in
  let e = Comp.add_position e pos in
  let e = Comp.add_velocity e vel in
  (e)

let make_falling_item ~pos =
  let e = Ent.new_entity () in
  let e = Comp.add_position e pos in
  let e = Comp.add_velocity e (0.0, -0.2) in
  (e)

let make_random_item () =
  let e = Ent.new_entity () in
  let e = Comp.add_position e (rand_xy ()) in
  let e = Comp.add_velocity e (rand_xy ()) in
  (e)

let make_item_defaults ?(pos=(0.0, 0.0)) ?(vel=(0.0, 0.0)) () =
  let e = Ent.new_entity () in
  let e = Comp.add_position e pos in
  let e = Comp.add_velocity e vel in
  (e)
