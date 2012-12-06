open Windowing
open State
open Comp

(* view *)

type view_data = {
  circ : SFCircleShape.t;
  text : SFText.t;
}

type t = {
  clic : int;
  paused : bool;
  continue : bool;
  app : App.t;
  view : view_data;
}

let circle_shape () =
  let pointCount = 32 in
  (SFCircleShape.create ~pointCount ())

let text_drawable () =
  let font = SFFont.createFromFile Vars.font_file in
  let text = SFText.create () in
  SFText.setFont text font;
  (text)

let init_view_data () =
  let circ = circle_shape () in
  let text = text_drawable () in
  { circ; text }

let init_view app =
  let clic = 0 in
  let paused = false in
  let continue = true in
  let view = init_view_data () in
  { clic; paused; continue; app; view }

let bounds_center text =
  let rect = SFText.getLocalBounds text in
  ((rect.SFRect.left +. rect.SFRect.width) /. 2.0,
   (rect.SFRect.top +. rect.SFRect.height) /. 2.0)

let draw_any_circle win circle pos radius color a =
  SFCircleShape.setFillColor circle (rgb_a color a);
  SFCircleShape.setRadius circle radius;
  SFCircleShape.setPosition circle (dir_sub pos radius);
  SFRenderWindow.drawCircleShape win circle ()

let white = (1.0, 1.0, 1.0)

let draw_text win text pos centered str size a =
  SFText.setColor text (rgb_a white a);
  SFText.setString text str;
  SFText.setCharacterSize text size;
  let pos =
    if centered
    then vec_sub pos (bounds_center text)
    else pos
  in
  SFText.setPosition text pos;
  SFRenderWindow.drawText win text ()

let draw_moving_circle e win view pos rad col =
  draw_any_circle win view.circ pos rad col 0.6

let draw_expanded_circle e win view pos rad col =
  draw_any_circle win view.circ pos rad col 0.4;
  if has_points e then begin
    let points = get_points e in
    let str = Printf.sprintf "%+d" points in
    draw_text win view.text pos true str 10 0.9;
  end

let draw_circle win a e pos col rad =
  match is_expanded e with
  | Some false -> draw_moving_circle e win a.view pos rad col
  | Some true -> draw_expanded_circle e win a.view pos rad col
  | None -> ()

let draw_item win a e =
  let pos = get_position_opt e in
  let col = get_color_opt e in
  let rad = get_radius_opt e in
  match pos, col, rad with
  | Some pos, Some col, Some rad ->
      draw_circle win a e pos col rad
  | _ -> ()

let draw_score win a =
  let str = App.user_infos a.app in
  draw_text win a.view.text (10.0, 8.0) false str 12 1.0

let bg_color = rgb (0.25, 0.25, 0.25)

let display a ~win ~t ~dt =
  Windowing.clear win bg_color;
  State.iter_entities (draw_item win a) a.app.App.state;
  draw_score win a;
  if a.paused then a else
  let app, clic = App.step a.app a.clic t dt in
  { a with app; clic }
