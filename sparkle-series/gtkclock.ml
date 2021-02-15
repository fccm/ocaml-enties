let pi = 4.0 *. atan 1.0
let angle v max = float v /. max *. 2.0 *. pi
let width, height = (640, 480)
let pos =
  Random.self_init ();
  Array.to_list (
    Array.init 16 (fun _ ->
      (Random.float (float width),
       Random.float (float height))))
 
let draw area _ =
  let cr = Cairo_lablgtk.create area#misc#window in
  let { Gtk.width = width; Gtk.height = height } = area#misc#allocation in
  let scale p = float (min width height) *. 0.5 *. p in
  let invert_y y = float height -. y in
  Cairo.set_source_rgb cr 0.3 0.4 0.5;
  Cairo.paint cr;
  Cairo.set_source_rgb cr 1.0 0.4 0.0;
  let point (x, y) =
    let r = scale 0.2 in
    Cairo.arc cr x (invert_y y) r 0.0 (2.0 *. pi);
    Cairo.fill cr;
  in
  List.iter point pos;
  (true)
 
let animate area =
  ignore (GMain.Timeout.add 200 (fun () ->
    GtkBase.Widget.queue_draw area#as_widget; true))
 
let () =
  let w = GWindow.window ~title:"OCaml GtkCairo" () in
  ignore (w#connect#destroy GMain.quit);
  let f = GBin.frame ~shadow_type:`IN ~packing:w#add () in
  let area = GMisc.drawing_area ~width ~height ~packing:f#add () in
  area#misc#set_double_buffered true;
  ignore (area#event#connect#expose (draw area));
  animate area;
  w#show ();
  GMain.main ()
