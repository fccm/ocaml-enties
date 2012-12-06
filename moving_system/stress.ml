open State

let rec repeat n f v =
  if n <= 0 then v
  else repeat (n-1) f (f v)

let time_of n f v =
  let t0 = Unix.gettimeofday () in
  ignore (repeat n f v);
  let t1 = Unix.gettimeofday () in
  let dt = t1 -. t0 in
  Printf.printf "%d frames in %g seconds\n" n dt;
  Printf.printf "%g steps per sec\n" (float n /. dt)

(* main *)
let () =
  Random.self_init ();
  let st = State.init_state () in
  let f st = State.state_step st ~t:0.0 ~dt:0.1 in
  time_of 10_000 f st
