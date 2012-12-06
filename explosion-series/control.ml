open State
open View

let mouse a ~t ~id ~button ~state ~x ~y =
  let pos x y = (float x, float y) in
  match button, state with
  | Windowing.Mouse_button_left, Windowing.Pressed ->
      let app = App.user_clic a.app t a.clic (pos x y) in
      { a with app; clic = a.clic + 1 }
  | _ ->
      (a)

let keyboard a ~t ~key ~state ~ctrl ~alt ~shift =
  match state, key with
  | Windowing.Pressed, Windowing.Char 'p' ->
      { a with paused = not (a.paused) }
  | Windowing.Pressed, Windowing.Char 's' ->
      let app, clic = App.step a.app a.clic t 1.0 in
      { a with app; clic }
  (*
  | Windowing.Pressed, Windowing.Char 'z' ->
      init_control a.w a.view
  *)
  | Windowing.Pressed, Windowing.Escape
  | Windowing.Pressed, Windowing.Char 'q' ->
      App.at_exit a.app;
      { a with continue = false }
  | Windowing.Pressed, Windowing.Char 'd' ->
      State.print_state a.app.App.state;
      (a)
  | _ ->
      (a)

let paused a = a.paused
let continue a ~t = a.continue
