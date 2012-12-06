type key =
  | Left | Right | Up | Down
  | Escape
  | Char of char  (* 'a' .. 'z' *)
  | Key of string

type switch_state =
  | Pressed
  | Released

type mouse_button =
  | Mouse_button_left
  | Mouse_button_middle
  | Mouse_button_right
  | Mouse_button_x of int
  | Mouse_wheel of int

let translate_button in_ev =
  match CL_InputEvent.get_mouse in_ev with
  | CL_Mouse.Left   -> Mouse_button_left
  | CL_Mouse.Right  -> Mouse_button_right
  | CL_Mouse.Middle -> Mouse_button_middle
  | CL_Mouse.XButton1 -> Mouse_button_x (1)
  | CL_Mouse.XButton2 -> Mouse_button_x (2)
  | CL_Mouse.Wheel_up   -> Mouse_wheel (1)
  | CL_Mouse.Wheel_down -> Mouse_wheel (-1)

let key_translate in_ev =
  let str = CL_InputEvent.str in_ev in
  match CL_InputEvent.get_key in_ev with
  | CL_Key.Left  -> Left
  | CL_Key.Right -> Right
  | CL_Key.Up    -> Up
  | CL_Key.Down  -> Down
  | CL_Key.Escape -> Escape
  | k when k >= CL_Key.A && k <= CL_Key.Z ->
      Char (Char.lowercase str.[0])
  | k -> Key (str)

let get_modifiers in_ev =
  (CL_InputEvent.ctrl in_ev,
   CL_InputEvent.alt in_ev,
   CL_InputEvent.shift in_ev)

let rgba r g b a = CL_Colorf.init ~r ~g ~b ~a ()
let rgb r g b = CL_Colorf.init ~r ~g ~b ()


let handle_event t keyboard_cb mouse_moved mouse_cb u id in_ev = function
  | CL_InputDevice.Keyboard, CL_InputEvent.Pressed ->
      let ctrl, alt, shift = get_modifiers in_ev in
      let key = key_translate in_ev in
      let state = Pressed in
      let u = keyboard_cb u ~t ~key ~state ~ctrl ~alt ~shift in
      (u)

  | CL_InputDevice.Keyboard, CL_InputEvent.Released ->
      let ctrl, alt, shift = get_modifiers in_ev in
      let key = key_translate in_ev in
      let state = Released in
      let u = keyboard_cb u ~t ~key ~state ~ctrl ~alt ~shift in
      (u)

  | CL_InputDevice.Pointer, CL_InputEvent.Pointer_moved ->
      let x, y = CL_InputEvent.mouse_pos in_ev in
      let u = mouse_moved u ~t ~id ~x ~y in
      (u)

  | CL_InputDevice.Pointer, CL_InputEvent.Pressed ->
      let x, y = CL_InputEvent.mouse_pos in_ev in
      let button = translate_button in_ev in
      let state = Pressed in
      let u = mouse_cb u ~t ~id ~button ~state ~x ~y in
      (u)

  | CL_InputDevice.Pointer, CL_InputEvent.Released ->
      let x, y = CL_InputEvent.mouse_pos in_ev in
      let button = translate_button in_ev in
      let state = Released in
      let u = mouse_cb u ~t ~id ~button ~state ~x ~y in
      (u)

  | CL_InputDevice.Keyboard, _
  | CL_InputDevice.Pointer, _ -> assert false

  | CL_InputDevice.Joystick, _ ->
      (* let axis = CL_InputEvent.axis_pos in_ev in *)
      (u)

  | CL_InputDevice.Tablet, _ -> assert false
  | CL_InputDevice.Unknown, _ -> assert false



let fold
    ?(window_size=640, 480)
    ?title
    ?init_gl
    ~init
    ~display
    ?reshape
    ?redisplay
    ?keyboard
    ?mouse_moved
    ?mouse
    ?fps
    ?continue
    ?paused
    () =

  let keyboard_cb =
    match keyboard with
    | Some cb -> cb
    | None -> (fun u ~t ~key ~state ~ctrl ~alt ~shift -> u)
  in

  let mouse_moved =
    match mouse_moved with
    | Some cb -> cb
    | None -> (fun u ~t ~id ~x ~y -> u)
  in

  let mouse_cb =
    match mouse with
    | Some cb -> cb
    | None -> (fun u ~t ~id ~button ~state ~x ~y -> u)
  in

  let redisplay =
    match redisplay with
    | Some cb -> cb
    | None -> (fun u ~t ~dt -> true)
  in

  CL_SetupCore.init ();
  CL_SetupDisplay.init ();
  CL_SetupGL.init ();

  let title = match title with Some v -> v | None -> Sys.argv.(0) in

  let width, height = window_size in
  let win = CL_DisplayWindow.init ~title ~width ~height in
  let gc = CL_DisplayWindow.get_gc win in
  let ic = CL_DisplayWindow.get_ic win in

  let ft =
    match (fps : int option) with
    | Some fps -> 1.0 /. float fps
    | None -> max_float
  in

  begin match init_gl with Some f -> f () | None -> () end;

  let u = init () in

  let reshape =
    match reshape with
    | Some cb -> cb
    | None -> (fun u ~width ~height -> u)
  in
  let u =
    let width, height = window_size in
    reshape u ~width ~height
  in

  let continue =
    match continue with Some f -> f
    | None -> (fun _ ~t -> true)
  in

  let paused =
    match paused with Some f -> f
    | None -> (fun _ -> false)
  in

  let keyboard = CL_InputContext.get_keyboard ic () in
  let mouse = CL_InputContext.get_mouse ~ic () in

  CL_InputEventQueue.connect_sig_key_down keyboard 0;
  CL_InputEventQueue.connect_sig_key_up keyboard 0;

  CL_InputEventQueue.connect_sig_key_down mouse 0;
  CL_InputEventQueue.connect_sig_key_up mouse 0;
  CL_InputEventQueue.connect_sig_pointer_move mouse 0;

  (*
  let joystick = CL_InputContext.get_joystick ~ic () in
  CL_InputEventQueue.connect_sig_key_down joystick 0;
  CL_InputEventQueue.connect_sig_key_up joystick 0;
  CL_InputEventQueue.connect_sig_axis_move joystick 0;
  *)

  let bm = CL_BlendMode.init () in
  CL_BlendMode.enable_blending bm true;

  (*
  CL_GraphicContext.clear gc (rgb 1.0 1.0 0.0);
  *)
  let get_time () =
    let t = CL_System.get_time () in
    (float t) /. 1000.
  in
  let t0 = get_time () in
  let n = ref 0 in
  let rec loop prev_t prev_frame_t u =
    let in_ev_lst = CL_InputEventQueue.get_input_events () in
    let t = get_time () in
    let u =
      List.fold_left (fun u (in_ev, dev_num, dev_kind) ->
        let id = (dev_num : int) in
        let u =
          handle_event t keyboard_cb mouse_moved mouse_cb u
            id in_ev (dev_kind, CL_InputEvent.get_type in_ev)
        in
        CL_InputEvent.delete in_ev;
        (u)

      ) u in_ev_lst
    in
    let dt = t -. prev_t in
    let u =
      if redisplay u ~t ~dt
      then display u ~gc ~t ~dt
      else u
    in
    let frame_t = get_time () in
    let fdt = frame_t -. prev_frame_t in
    let () =
      if fdt < ft then
        let slt = (ft -. fdt) *. 1000.0 in
        CL_System.sleep (int_of_float slt)
    in
    CL_DisplayWindow.flip win;
    CL_KeepAlive.process ();
    incr n;
    let rec pause u t =
      if paused u
      then begin
        CL_System.sleep 100;
        pause u t
      end else
        let et = get_time () in
        (u, et -. t)
    in
    let u, _ = pause u t in
    if continue u ~t
    then loop t frame_t u
    else (u)
  in
  let u = loop t0 t0 u in
  let t1 = get_time () in
  let dt = (t1 -. t0) in
  let n = float !n in
  let fps = n /. dt in
  Printf.printf "fps: %g\n%!" fps;
  CL_DisplayWindow.delete win;
  (u)
