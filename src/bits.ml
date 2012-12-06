let rec _bits acc d =
  if d = 0 then acc
  else _bits ((d land 1)::acc) (d lsr 1)

let bits d = _bits [] d

let bits_match bs1 bs2 =
  let rec aux = function
  | (b1::bs1), (b2::bs2) ->
      ((b1 land b2) = b2) && aux (bs1, bs2)
  | [], [] -> true
  | _ -> false
  in
  aux (bs1, bs2)

let () =
  let d1 = 0b1101000_11000100_11111010_01110101 in
  let d2 = 0b1000000_11000000_10111000_00110101 in
  let d3 = d1 land d2 in
  let d4 = 0b1010011_01011110_01111010_01110101 in
  let d5 = 0b1000000_01000000_00111000_00110101 in
  let b1 = bits d1 in
  let b2 = bits d2 in
  let b3 = bits d3 in
  List.iter (Printf.printf "%d") b1; print_newline ();
  List.iter (Printf.printf "%d") b2; print_newline ();
  List.iter (Printf.printf "%d") b3; print_newline ();
  Printf.printf "match: %B\n" ((d1 land d2) = d2);
  Printf.printf "match: %B\n" (bits_match [d1;d4] [d2;d5]);
;;
