open State
open View

(* frame per second *)

let fps = 60

(* init app_data *)

let init () =
  let w = State.init_state () in
  let app = View.init_app_data w in
  (app)

(* main *)

let _ =
  Random.self_init ();
  let title = Sys.argv.(0) in
  Windowing.fold
    ~window_size:(width, height)
    ~title
    ~init
    ~display
    ~mouse
    ~keyboard
    ~paused
    ~continue
    ~fps
    ()
