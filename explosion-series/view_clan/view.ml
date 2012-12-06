open State
open Comp

(* view *)

type view_data = {
  mutable fonts : (int * CL_Font.t) list;
}

type t = {
  clic : int;
  paused : bool;
  continue : bool;
  app : App.t;
  view : view_data;
}

let make_font gc size =
  (*
  let typeface = "Tahoma" in
  *)
  let typeface = Vars.font_file in
  let desc = CL_FontDescription.init () in
  CL_FontDescription.set_anti_alias desc;
  CL_FontDescription.set_typeface_name desc typeface;
  CL_FontDescription.set_height desc size;
  (CL_Font.of_desc ~gc ~desc)

let push_fonts gc view size =
  let font = make_font gc size in
  view.fonts <- (size, font) :: view.fonts;
  (font)

let init_view app =
  let clic = 0 in
  let paused = false in
  let continue = true in
  let view = { fonts = [] } in
  { clic; paused; continue; view; app }

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

let rgb (r, g, b) =
  CL_Colorf.init ~r ~g ~b ()

let rgb_a (r, g, b) a =
  CL_Colorf.init ~r ~g ~b ~a ()

let draw_any_circle gc center radius color a =
  let color = (rgb_a color a) in
  CL_Draw.circle ~gc ~center ~radius ~color

let get_font gc view size =
  try List.assoc size view.fonts
  with Not_found ->
    push_fonts gc view size

let white = rgb (1.0, 1.0, 1.0)

let draw_text gc view pos centered text size a =
  let font = get_font gc view size in
  let pos =
    if centered
    then vec_sub pos (bounds_center gc font text)
    else pos
  in
  CL_Font.draw_text ~font ~gc ~pos ~text ~color:white ()

let draw_moving_circle e gc a pos rad col =
  draw_any_circle gc pos rad col 0.6

let draw_expanded_circle e gc a pos rad col =
  draw_any_circle gc pos rad col 0.4;
  if has_points e then begin
    let points = get_points e in
    let str = Printf.sprintf "%+d" points in
    draw_text gc a.view pos true str 14 0.9;
  end

let draw_circle gc a e pos col rad =
  match is_expanded e with
  | Some false -> draw_moving_circle e gc a pos rad col
  | Some true -> draw_expanded_circle e gc a pos rad col
  | None -> ()

let draw_item gc a e =
  let pos = get_position_opt e in
  let col = get_color_opt e in
  let rad = get_radius_opt e in
  match pos, col, rad with
  | Some pos, Some col, Some rad ->
      draw_circle gc a e pos col rad
  | _ -> ()

let draw_score gc a =
  let str = App.user_infos a.app in
  draw_text gc a.view (8.0, 14.0) false str 16 1.0

let bg_color = rgb (0.25, 0.25, 0.25)

let display a ~gc ~t ~dt =
  CL_GraphicContext.clear gc bg_color;
  State.iter_entities (draw_item gc a) a.app.App.state;
  draw_score gc a;
  if a.paused then a else
  let app, clic = App.step a.app a.clic t dt in
  { a with app; clic }
