type xy = float * float
type rgb = float * float * float

let string_of_xy (x, y) =
  Printf.sprintf "(%g, %g)" x y

let string_of_rgb (r, g, b) =
  Printf.sprintf "(%.3g, %.3g, %.3g)" r g b

