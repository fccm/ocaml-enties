type point = float * float
type time = float

let along ~t1 ~t2 ~p1:(x1, y1) ~p2:(x2, y2) =
  let t_diff = t2 -. t1 in
  let x = (x2 -. x1) /. t_diff
  and y = (y2 -. y1) /. t_diff in
  function t ->
    let dt = t -. t1 in
    (x1 +. (dt *. x),
     y1 +. (dt *. y))
