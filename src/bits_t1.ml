let n = 10_000_000

let f (d1, d2) =
  for i = 1 to n do
    ignore ((d1 land d2) = d2)
  done

let time f v =
  let t0 = Unix.gettimeofday () in
  f v;
  let t1 = Unix.gettimeofday () in
  let dt = (t1 -. t0) in
  Printf.printf "time: %d / %f\n" n dt

let () =
  let d1 = 0b1101000_11000100_11111010_01110101 in
  let d2 = 0b1000000_11000000_10111000_00110101 in
  time f (d1, d2)
;;
