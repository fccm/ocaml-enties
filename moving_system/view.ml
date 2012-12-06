(* vars *)

let background_color = (0.28, 0.28, 0.28)

(* view *)

type app_data = {
  state : State.t;
  circ : SFCircleShape.t;
  paused : bool;
  continue : bool;
}

let circle_shape () =
  let pointCount = 32 in
  (SFCircleShape.create ~pointCount ())

let init_app_data state =
  let circ = circle_shape () in
  let paused = false in
  let continue = true in
  { state; circ; paused; continue }

let dir_sub (x, y) v =
  (x -. v,
   y -. v)

let rgb (r, g, b) =
  let c v = int_of_float (v *. 255.0) in
  SFColor.RGB (c r, c g, c b)

let rgb_a (r, g, b) a =
  let c v = int_of_float (v *. 255.0) in
  SFColor.RGBA (c r, c g, c b, c a)

let draw_circle win circle pos radius color a =
  SFCircleShape.setFillColor circle (rgb_a color a);
  SFCircleShape.setRadius circle radius;
  SFCircleShape.setPosition circle (dir_sub pos radius);
  SFRenderWindow.drawCircleShape win circle ()

let draw_moving_circle win a pos rad col =
  draw_circle win a.circ pos rad col 0.6

let draw_item win a e =
  let pos = Comp.get_position_opt e in
  let rad = Comp.get_radius_opt e in
  let col = Comp.get_color_opt e in
  match pos, rad, col with
  | Some pos, Some rad, Some col ->
      draw_moving_circle win a pos rad col
  | _ -> ()

let display a ~win ~t ~dt =
  SFRenderWindow.clear win (rgb background_color);
  State.iter_items (draw_item win a) a.state;
  let state =
    if a.paused then (a.state)
    else State.state_step a.state ~t ~dt
  in
  { a with state }

(* control *)

let keyboard a ~t ~key ~state ~ctrl ~alt ~shift =
  match state, key with
  | Windowing.Pressed, Windowing.Char 'P' ->
      { a with paused = not (a.paused) }
  | Windowing.Pressed, Windowing.Char 'S' ->
      let state = State.state_step a.state t 1.0 in  (* add one second *)
      { a with state }
  | Windowing.Pressed, Windowing.Char 'Z' ->
      let state = State.init_state () in
      { a with state }
  | Windowing.Pressed, Windowing.Char 'D' ->
      State.print_state a.state;
      (a)
  | Windowing.Pressed, Windowing.Escape
  | Windowing.Pressed, Windowing.Char 'q' ->
      { a with continue = false }
  | _ ->
      (a)

let mouse a ~t ~id ~button ~state ~x ~y =
  Printf.printf " # %d %d\n%!" x y;
  (a)

let paused a = a.paused
let continue a ~t = a.continue
