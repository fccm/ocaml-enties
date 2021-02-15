type window_handle = SFRenderWindow.t
type color = SFColor.t

let rgb (r, g, b) =
  let c v = int_of_float (v *. 255.0) in
  SFColor.RGB (c r, c g, c b)

let rgb_a (r, g, b) a =
  let c v = int_of_float (v *. 255.0) in
  SFColor.RGBA (c r, c g, c b, c a)

let clear win color =
  SFRenderWindow.clear win color


type app = {
  win: SFRenderWindow.t;
  clock: SFPausableClock.t;
  prev_time: float;
}


let elapsed_time a =
  SFTime.asSeconds (
    SFPausableClock.getElapsedTime a.clock)


let render display redisplay t a u =
  let dt = t -. a.prev_time in
  if redisplay u ~t ~dt then
  begin
    let u = display u ~win:a.win ~t ~dt in
    SFRenderWindow.display a.win;
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
  | SFMouse.ButtonLeft   -> Mouse_button_left
  | SFMouse.ButtonRight  -> Mouse_button_right
  | SFMouse.ButtonMiddle -> Mouse_button_middle
  | SFMouse.ButtonX1     -> Mouse_button_x 1
  | SFMouse.ButtonX2     -> Mouse_button_x 2

let key_translate = function
  | SFKey.Left  -> Left
  | SFKey.Right -> Right
  | SFKey.Up    -> Up
  | SFKey.Down  -> Down
  | SFKey.Escape -> Escape
  | k when k >= SFKey.A && k <= SFKey.Z ->
      Char (Char.lowercase_ascii (SFKey.string_of_keyCode k).[0])
  | k -> Key (SFKey.string_of_keyCode k)


let handle_event t reshape keyboard mouse_moved mouse u = function
  | SFEvent.MouseMoved (x, y) ->
      let id = 0 in  (* SFML doesn't handle several mice yet *)
      let u = mouse_moved u ~t ~id ~x ~y in
      (u)

  | SFEvent.KeyPressed (key, alt, ctrl, shift, _) ->
      let key = key_translate key and state = Pressed in
      let u = keyboard u ~t ~key ~state ~ctrl ~alt ~shift in
      (u)

  | SFEvent.KeyReleased (key, alt, ctrl, shift, _) ->
      let key = key_translate key and state = Released in
      let u = keyboard u ~t ~key ~state ~ctrl ~alt ~shift in
      (u)

  | SFEvent.Resized (width, height) ->
      let u = reshape u ~width ~height in
      (u)

  | SFEvent.MouseButtonPressed (mbut, x, y) ->
      let id = 0 in  (* SFML doesn't handle several mice yet *)
      let button = mouse_translate mbut and state = Pressed in
      let u = mouse u ~t ~id ~button ~state ~x ~y in
      (u)

  | SFEvent.MouseButtonReleased (mbut, x, y) ->
      let id = 0 in  (* SFML doesn't handle several mice yet *)
      let button = mouse_translate mbut and state = Released in
      let u = mouse u ~t ~id ~button ~state ~x ~y in
      (u)

  | SFEvent.MouseWheelScrolled (_, delta, x, y) ->
      let id = 0 in  (* SFML doesn't handle several mice yet *)
      let state = if delta > 0.0 then Pressed else Released
      and button = Mouse_wheel (int_of_float delta) in
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

  let title = match title with Some v -> v | None -> Sys.argv.(0) in

  (*
  let win = SFRenderWindow.make window_size title in
  *)
  let win =
    let width, height = window_size in
    let style = [SFStyle.Titlebar; SFStyle.Close] in
    let style =
      if reshape = None then style
      else (SFStyle.Resize :: style)
    in
    let mode =
      { SFVideoMode.
        width;
        height;
        bitsPerPixel = 32;
      }
    and settings =
      { SFContextSettings.default with
        SFContextSettings.
        depthBits = 24;
        stencilBits = 8;
        antialiasingLevel = 4;
        majorVersion = 2;
        minorVersion = 1;
      }
    in
    SFRenderWindow.create ~mode ~title ~style ~settings
  in

  begin match fps with None -> ()
  | Some fps -> SFRenderWindow.setFramerateLimit win fps
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

  let clock = SFPausableClock.create ~paused:false in

  let continue =
    match continue with Some f -> f
    | None -> (fun _ ~t -> true)
  in

  let paused =
    match paused with Some f -> f
    | None -> (fun _ -> false)
  in

  let t0 = SFTime.asSeconds (SFPausableClock.getElapsedTime clock) in

  let a = { win; clock; prev_time = t0 } in

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

  let rec loop a u =
    let t = elapsed_time a in
    let rec ev_loop u =
      match SFRenderWindow.pollEvent a.win with
      | Some SFEvent.Closed -> u, true
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
