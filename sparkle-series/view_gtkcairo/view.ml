open State
open Comp

(* view *)

type view_data = {
  mutable fonts : int list;
}

type t = {
  clic : int;
  paused : bool;
  continue : bool;
  app : App.t;
  view : view_data;
}

let pi = 4.0 *. atan 1.0

let rgb cr (r, g, b) =
  Cairo.set_source_rgb cr r g b

let rgb_a cr (r, g, b) a =
  Cairo.set_source_rgba cr r g b a

(*
let bounds_center gc font text =
  let size =
    CL_Font.get_text_size ~font ~gc ~text
  in
  let width = size.CL_Sizef.width
  and height = size.CL_Sizef.height in
  (width /. 2.0,
   height /. 2.0)

let bounds_center gc font text =
  (10.0, 0.0)
*)

let draw_any_circle cr (width, height) (x, y) radius color a =
  let invert_y y = float height -. y in
  rgb_a cr color a;
  Cairo.arc cr x (invert_y y) radius 0.0 (2.0 *. pi);
  Cairo.fill cr

let white cr = rgb cr (1.0, 1.0, 1.0)

let draw_text gc (width, height) view pos centered text size a =
  (*
  let pos =
    if centered
    then vec_sub pos (bounds_center gc font text)
    else pos
  in
  CL_Font.draw_text ~font ~gc ~pos ~text ~color:white ()
  *)
  ()

let draw_moving_circle e gc w_dims a pos rad col =
  draw_any_circle gc w_dims pos rad col 0.6

let draw_expanded_circle e gc w_dims a pos rad col =
  draw_any_circle gc w_dims pos rad col 0.4;
  if has_points e then begin
    let points = get_points e in
    let str = Printf.sprintf "%+d" points in
    draw_text gc w_dims a.view pos true str 14 0.9;
  end

let draw_circle gc w_dims a e pos col rad =
  match is_expanded e with
  | Some false -> draw_moving_circle e gc w_dims a pos rad col
  | Some true -> draw_expanded_circle e gc w_dims a pos rad col
  | None -> ()

let draw_item cr w_dims a e =
  let pos = get_position_opt e in
  let col = get_color_opt e in
  let rad = get_radius_opt e in
  match pos, col, rad with
  | Some pos, Some col, Some rad ->
      draw_circle cr w_dims a e pos col rad
  | _ -> ()

let draw_score cr w_dims a =
  let str = App.user_infos a.app in
  draw_text cr w_dims a.view (8.0, 14.0) false str 16 1.0

let bg_color cr = rgb cr (0.25, 0.25, 0.25)

let display a ~area ~t ~dt =
  let cr = Cairo_lablgtk.create area#misc#window in
  let { Gtk.width = width; Gtk.height = height } = area#misc#allocation in
  bg_color cr;
  Cairo.paint cr;
  State.iter_entities (draw_item cr (width, height) a) a.app.App.state;
  draw_score cr (width, height) a;
  GtkBase.Widget.queue_draw area#as_widget;
  if a.paused then a else
  let app, clic = App.step a.app a.clic t dt in
  { a with app; clic }

let draw area _ =
  (true)
 
let init_win () =
  let width, height = Vars.window_size in
  let w = GWindow.window ~title:Sys.argv.(0) () in
  ignore (w#connect#destroy GMain.quit);
  let f = GBin.frame ~shadow_type:`IN ~packing:w#add () in
  let area = GMisc.drawing_area ~width ~height ~packing:f#add () in
  area#misc#set_double_buffered true;
  ignore (area#event#connect#expose (draw area));
  w#show ();
  GMain.main ()

let init_view app =
  let _ = init_win () in
  let clic = 0 in
  let paused = false in
  let continue = true in
  let view = { fonts = [] } in
  { clic; paused; continue; view; app }

