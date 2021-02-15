open State
open Comp

(* view *)

type view_data = {
  rect : Sdlvideo.rect;
  fonts : (int * Sdlttf.font) list;
}

type t = {
  clic : int;
  paused : bool;
  continue : bool;
  app : App.t;
  view : view_data;
}

let width, height = Vars.window_size

let init_view_data () =
  Sdlttf.init ();
  let rect = { Sdlvideo.r_x = 0; r_y = 0; r_w = width; r_h = height } in
  let font10 = Sdlttf.open_font Vars.font_file 10 in
  let font12 = Sdlttf.open_font Vars.font_file 12 in
  { rect; fonts = [(10, font10); (12, font12)] }

let init_view app =
  let clic = 0 in
  let paused = false in
  let continue = true in
  let view = init_view_data () in
  { clic; paused; continue; app; view }

(*
let bounds_center text =
  let rect = SFText.getLocalBounds text in
  ((rect.SFRect.left +. rect.SFRect.width) /. 2.0,
   (rect.SFRect.top +. rect.SFRect.height) /. 2.0)
*)

(*
let rgb (r, g, b) =
  let c v = int_of_float (v *. 255.0) in
  SFColor.RGB (c r, c g, c b)

let rgb_a (r, g, b) a =
  let c v = int_of_float (v *. 255.0) in
  SFColor.RGBA (c r, c g, c b, c a)
*)

let int32_rgb (r, g, b) =
  let r = int_of_float (r *. 255.0)
  and g = int_of_float (g *. 255.0)
  and b = int_of_float (b *. 255.0) in
  Int32.of_int ((r lsl 16) lor (g lsl 8) lor (b))

let color_rgb (r, g, b) =
  let r = int_of_float (r *. 255.0)
  and g = int_of_float (g *. 255.0)
  and b = int_of_float (b *. 255.0) in
  (r, g, b)

let int32_rgba (r, g, b) a =
  let r = int_of_float (r *. 255.0)
  and g = int_of_float (g *. 255.0)
  and b = int_of_float (b *. 255.0)
  and a = int_of_float (a *. 255.0) in
  let gba = Int32.of_int ((g lsl 16) lor (b lsl 8) lor (a))
  and r = Int32.of_int r in
  Int32.logor gba (Int32.shift_left r 24)

let draw_any_circle surf pos radius color a =
(*
  SFCircleShape.setFillColor circle (rgb_a color a);
  (*
  SFCircleShape.setFillColor circle SFColor.transparent;
  SFCircleShape.setOutlineColor ~circle ~color:(rgb color);
  SFCircleShape.setOutlineThickness ~circle ~thickness:2.0;
  *)
  SFCircleShape.setRadius circle radius;
  SFCircleShape.setPosition circle (dir_sub pos radius);
  SFRenderWindow.drawCircleShape win circle ()
*)
  (*
  let a = int_of_float (a *. 255.0) in
  Sdlgfx.filledCircleRGBA surf x y radius (color_rgb color) a
  *)
  let int_pos (x, y) =
    (int_of_float x,
     int_of_float y)
  in
  let radius = int_of_float radius in
  let rgba = (int32_rgba color a) in
  Sdlgfx.filledCircleColor surf (int_pos pos) radius rgba

let draw_text surf a (x, y) centered str size alpha =
  let font = List.assoc size a.view.fonts in
  let txt = Sdlttf.render_text_solid font str (255, 255, 255) in
  let dst_rect = { Sdlvideo.
    r_x = truncate x;
    r_y = truncate y;
    r_w = 0;
    r_h = 0;
  } in
  Sdlvideo.blit_surface ~src:txt ~dst:surf ~dst_rect ()
(*
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
*)

let draw_moving_circle e surf a pos rad col =
  draw_any_circle surf pos rad col 0.6

let draw_expanded_circle e surf a pos rad col =
  draw_any_circle surf pos rad col 0.4;
  if has_points e then begin
    let points = get_points e in
    let str = Printf.sprintf "%+d" points in
    draw_text surf a pos true str 10 0.9;
  end

let draw_circle surf a e pos col rad =
  match is_expanded e with
  | Some false -> draw_moving_circle e surf a pos rad col
  | Some true -> draw_expanded_circle e surf a pos rad col
  | None -> ()

let draw_item surf a e =
  let pos = get_position_opt e in
  let col = get_color_opt e in
  let rad = get_radius_opt e in
  match pos, col, rad with
  | Some pos, Some col, Some rad ->
      draw_circle surf a e pos col rad
  | _ -> ()

let draw_score surf a =
  let str = App.user_infos a.app in
  draw_text surf a (10.0, 10.0) false str 12 1.0

let bg_color = int32_rgb (0.25, 0.25, 0.25)

let display a ~surface ~t ~dt =
  Sdlvideo.fill_rect ~rect:a.view.rect surface bg_color;
  State.iter_entities (draw_item surface a) a.app.App.state;
  draw_score surface a;
  if a.paused then a else
  let app, clic = App.step a.app a.clic t dt in
  { a with app; clic }
