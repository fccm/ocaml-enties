
type app = {
  surface: Sdlvideo.surface;
  prev_time: float;
}

let elapsed_time () =
  let millisec = Sdltimer.get_ticks () in
  (float millisec) /. 1000.0


let render display redisplay t a u =
  let dt = t -. a.prev_time in
  if redisplay u ~t ~dt then
  begin
    let u = display u ~surface:a.surface ~t ~dt in
    Sdlvideo.flip a.surface;
    { a with prev_time = t }, u
  end else
    { a with prev_time = a.prev_time }, u


type key =
  | Left | Right | Up | Down
  | Escape
  | Char of char
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

let mouse_translate = function
  | Sdlmouse.BUTTON_LEFT      -> Mouse_button_left
  | Sdlmouse.BUTTON_RIGHT     -> Mouse_button_right
  | Sdlmouse.BUTTON_MIDDLE    -> Mouse_button_middle
  | Sdlmouse.BUTTON_WHEELUP   -> Mouse_wheel 1
  | Sdlmouse.BUTTON_WHEELDOWN -> Mouse_wheel (-1)
  | Sdlmouse.BUTTON_X x       -> Mouse_button_x x

let key_translate = function
  | Sdlkey.KEY_LEFT   -> Left
  | Sdlkey.KEY_RIGHT  -> Right
  | Sdlkey.KEY_UP     -> Up
  | Sdlkey.KEY_DOWN   -> Down
  | Sdlkey.KEY_ESCAPE -> Escape

  | k when k >= Sdlkey.KEY_a && k <= Sdlkey.KEY_z ->
      Char (Char.lowercase (Sdlkey.char_of_key k))
  | k -> Key (Sdlkey.name k)


let handle_event t reshape keyboard mouse_moved mouse u = function
  | Sdlevent.MOUSEMOTION mm_ev ->
      let x = mm_ev.Sdlevent.mme_x
      and y = mm_ev.Sdlevent.mme_y
      and id = mm_ev.Sdlevent.mme_which in
      let u = mouse_moved u ~t ~id ~x ~y in
      (u)

  | Sdlevent.KEYDOWN key_ev ->
      let key = key_translate key_ev.Sdlevent.keysym
      and state = Pressed in
      let ctrl = (key_ev.Sdlevent.keymod land Sdlkey.kmod_ctrl) <> 0
      and shift = (key_ev.Sdlevent.keymod land Sdlkey.kmod_shift) <> 0
      and alt = (key_ev.Sdlevent.keymod land Sdlkey.kmod_alt) <> 0 in
      let u = keyboard u ~t ~key ~state ~ctrl ~alt ~shift in
      (u)

  | Sdlevent.KEYUP key_ev ->
      let key = key_translate key_ev.Sdlevent.keysym
      and state = Released in
      let ctrl = (key_ev.Sdlevent.keymod land Sdlkey.kmod_ctrl) <> 0
      and shift = (key_ev.Sdlevent.keymod land Sdlkey.kmod_shift) <> 0
      and alt = (key_ev.Sdlevent.keymod land Sdlkey.kmod_alt) <> 0 in
      let u = keyboard u ~t ~key ~state ~ctrl ~alt ~shift in
      (u)

  | Sdlevent.VIDEORESIZE (width, height) ->
      let u = reshape u ~width ~height in
      (u)

  | Sdlevent.MOUSEBUTTONDOWN mb_ev ->
      let id = mb_ev.Sdlevent.mbe_which in
      let button = mouse_translate mb_ev.Sdlevent.mbe_button
      and state = Pressed in
      let x = mb_ev.Sdlevent.mbe_x
      and y = mb_ev.Sdlevent.mbe_y in
      let u = mouse u ~t ~id ~button ~state ~x ~y in
      (u)

  | Sdlevent.MOUSEBUTTONUP mb_ev ->
      let id = mb_ev.Sdlevent.mbe_which in
      let button = mouse_translate mb_ev.Sdlevent.mbe_button
      and state = Released in
      let x = mb_ev.Sdlevent.mbe_x
      and y = mb_ev.Sdlevent.mbe_y in
      let u = mouse u ~t ~id ~button ~state ~x ~y in
      (u)

  | _ -> u


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

  Sdl.init [`VIDEO; `JOYSTICK];

  (*
  if fullscreen then
    if not(Sdlwm.toggle_fullscreen()) then
      prerr_endline "fullscreen failed";
  Sdlmouse.show_cursor false;
  Sdlmouse.warp (width/2) (height/2);
  let num_joysticks = Sdljoystick.num_joysticks () in
  joy_arr := (Array.init num_joysticks Sdljoystick.open_joystick);
  *)

  (* ============================= *)

  let title = match title with Some v -> v | None -> Sys.argv.(0) in
  Sdlwm.set_caption ~title ~icon:"";

  (*
  let win = SFRenderWindow.make window_size title in
  *)
  let surface =
    let width, height = window_size in
    let style = [`HWSURFACE; `DOUBLEBUF] in
    let style =
      if reshape = None then style
      else `RESIZABLE :: style
    in
    (*
    type modes = NOMODE | ANY | DIM of (int * int) list
    val list_modes : ?bpp:int -> video_flag list -> modes
    val video_mode_ok : w:int -> h:int -> bpp:int -> video_flag list -> int
    *)
    (Sdlvideo.set_video_mode ~w:width ~h:height ~bpp:0 style)
  in

  begin match fps with None -> ()
  (*
  | Some fps -> SFRenderWindow.setFramerateLimit win fps
  *)
  | Some fps -> prerr_endline " # TODO fps"
  end;

  begin match init_gl with Some f -> f () | None -> () end;

  let keyboard =
    match keyboard with
    | Some cb -> cb
    | None -> (fun u ~t ~key ~state ~ctrl ~alt ~shift -> u)
  in

  let mouse_moved =
    match mouse_moved with
    | Some cb -> cb
    | None -> (fun u ~t ~id ~x ~y -> u)
  in

  let mouse =
    match mouse with
    | Some cb -> cb
    | None -> (fun u ~t ~id ~button ~state ~x ~y -> u)
  in

  let redisplay =
    match redisplay with
    | Some cb -> cb
    | None -> (fun u ~t ~dt -> true)
  in

  let continue =
    match continue with Some f -> f
    | None -> (fun _ ~t -> true)
  in

  let paused =
    match paused with Some f -> f
    | None -> (fun _ -> false)
  in

  let t0 = elapsed_time () in

  let a = { surface; prev_time = t0 } in

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

  (* TODO
  let check_paused u a =
    let is_paused = SFPausableClock.isPaused a.clock in
    match paused u, is_paused with
    | true, true
    | false, false -> ()
    | true, false ->
        SFPausableClock.pause a.clock
    | false, true ->
        SFPausableClock.start a.clock
  in
  *)
  let check_paused u a =
    match paused u with
    | true -> ()
    | false -> ()
  in

  let rec loop a u =
    let t = elapsed_time () in
    let rec ev_loop u =
      (*
      Sdljoystick.update (get_joy 0); (* XXX fixme *)
      *)
      match Sdlevent.poll () with
      (*
      | Some SFEvent.KeyPressed (SFKey.Escape,_,_,_,_)  (* XXX: while dev *)
      | Some SFEvent.Closed -> u, true
      *)
      | Some Sdlevent.QUIT -> u, true
      | Some event ->
          let u = handle_event t reshape keyboard mouse_moved mouse u event in
          ev_loop u
      | None -> u, false
    in
    let u, exit = ev_loop u in
    if exit then u else
    let () = check_paused u a in
    let a, u = render display redisplay t a u in
    if continue u ~t
    then loop a u
    else u
  in
  loop a u
