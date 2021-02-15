open Vars
open State
open View
open Control

(* main init *)

let init () =
  let difficulty = 0.4 in
  let new_round ~score ~difficulty =
    (score, difficulty +. 0.2)
  in
  let app = App.init_app ~difficulty ~new_round in
  let view = View.init_view app in
  (view)

(* main *)

let _ =
  Random.self_init ();
  Windowing.fold
    ~window_size
    ~title:"Explosion Series"
    ~init
    ~display
    ~mouse
    ~keyboard
    ~continue
    ~paused
    ~fps
    ()
