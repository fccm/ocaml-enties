(* === bal === *)

(* Bat *)

let height = function
  | Node (_, _, _, _, h) -> h
  | Empty -> 0

(* The create and bal functions are from stdlib's map.ml (3.12)
   differences from the old (extlib) implementation :

   1. create use direct integer comparison instead of calling
   polymorphic 'max'

   2. the two calls of 'height' for hl and hr in the beginning of 'bal'
   (hot path) are inlined

   The difference in performances is important for bal-heavy worflows,
   such as "adding a lot of elements". On a test system, we go from
   1800 op/s to 2500 op/s.
*)
let create l x d r =
  let hl = height l and hr = height r in
  Node(l, x, d, r, (if hl >= hr then hl + 1 else hr + 1))

let bal l x d r =
  let hl = match l with Empty -> 0 | Node(_,_,_,_,h) -> h in
  let hr = match r with Empty -> 0 | Node(_,_,_,_,h) -> h in
  if hl > hr + 2 then begin
    match l with
    | Empty -> invalid_arg "Map.bal"
    | Node(ll, lv, ld, lr, _) ->
        if height ll >= height lr then
          create ll lv ld (create lr x d r)
        else begin
          match lr with
          | Empty -> invalid_arg "Map.bal"
          | Node(lrl, lrv, lrd, lrr, _)->
              create (create ll lv ld lrl) lrv lrd (create lrr x d r)
        end
  end else if hr > hl + 2 then begin
    match r with
    | Empty -> invalid_arg "Map.bal"
    | Node(rl, rv, rd, rr, _) ->
        if height rr >= height rl then
          create (create l x d rl) rv rd rr
        else begin
          match rl with
          | Empty -> invalid_arg "Map.bal"
          | Node(rll, rlv, rld, rlr, _) ->
              create (create l x d rll) rlv rld (create rlr rv rd rr)
        end
  end else
    Node(l, x, d, r, (if hl >= hr then hl + 1 else hr + 1))

(* std-lib *)
let height = function
  | Empty -> 0
  | Node(_,_,_,_,h) -> h

let create l x d r =
  let hl = height l and hr = height r in
  Node(l, x, d, r, (if hl >= hr then hl + 1 else hr + 1))

let bal l x d r =
  let hl = match l with Empty -> 0 | Node(_,_,_,_,h) -> h in
  let hr = match r with Empty -> 0 | Node(_,_,_,_,h) -> h in
  if hl > hr + 2 then begin
    match l with
    | Empty -> invalid_arg "Map.bal"
    | Node(ll, lv, ld, lr, _) ->
        if height ll >= height lr then
          create ll lv ld (create lr x d r)
        else begin
          match lr with
          | Empty -> invalid_arg "Map.bal"
          | Node(lrl, lrv, lrd, lrr, _)->
              create (create ll lv ld lrl) lrv lrd (create lrr x d r)
        end
  end else if hr > hl + 2 then begin
    match r with
    | Empty -> invalid_arg "Map.bal"
    | Node(rl, rv, rd, rr, _) ->
        if height rr >= height rl then
          create (create l x d rl) rv rd rr
        else begin
          match rl with
            Empty -> invalid_arg "Map.bal"
          | Node(rll, rlv, rld, rlr, _) ->
              create (create l x d rll) rlv rld (create rlr rv rd rr)
        end
  end else
    Node(l, x, d, r, (if hl >= hr then hl + 1 else hr + 1))


(* === merge === *)

(* Bat *)
let rec min_binding = function
  | Node (Empty, k, v, _, _) -> k, v
  | Node (l, _, _, _, _) -> min_binding l
  | Empty -> raise Not_found

let rec remove_min_binding = function
  | Node (Empty, _, _, r, _) -> r
  | Node (l, k, v, r, _) -> bal (remove_min_binding l) k v r
  | Empty -> invalid_arg "PMap.remove_min_binding"

let merge t1 t2 =
  match t1, t2 with
  | Empty, _ -> t2
  | _, Empty -> t1
  | _ ->
      let k, v = min_binding t2 in
      bal t1 k v (remove_min_binding t2)

(* std-lib *)

let rec min_binding = function
  | Empty -> raise Not_found
  | Node(Empty, x, d, r, _) -> (x, d)
  | Node(l, x, d, r, _) -> min_binding l

let rec remove_min_binding = function
  | Empty -> invalid_arg "Map.remove_min_elt"
  | Node(Empty, x, d, r, _) -> r
  | Node(l, x, d, r, _) -> bal (remove_min_binding l) x d r

let merge t1 t2 =
  match (t1, t2) with
  | (Empty, t) -> t
  | (t, Empty) -> t
  | (_, _) ->
      let (x, d) = min_binding t2 in
      bal t1 x d (remove_min_binding t2)


(* === add === *)

(* std-lib *)
let rec add x data cmp = function
  | Empty ->
      Node(Empty, x, data, Empty, 1)
  | Node(l, v, d, r, h) ->
      let c = cmp x v in
      if c = 0 then
        Node(l, x, data, r, h)
      else if c < 0 then
        bal (add x data cmp l) v d r
      else
        bal l v d (add x data cmp r)

(* Bat *)
let add x d cmp map =
  let rec loop = function
  | Node (l, k, v, r, h) ->
      let c = cmp x k in
      if c = 0 then Node (l, x, d, r, h)
      else if c < 0 then
        let nl = loop l in
        bal nl k v r
      else
        let nr = loop r in
        bal l k v nr
  | Empty -> Node (Empty, x, d, Empty, 1) in
  loop map


(* === fold === *)

(* std-lib *)
let rec fold f m accu =
  match m with
  | Empty -> accu
  | Node(l, v, d, r, _) ->
      fold f r (f v d (fold f l accu))

(* Bat *)
let fold f map acc =
  let rec loop acc = function
  | Empty -> acc
  | Node (l, k, v, r, _) ->
      loop (f v (loop acc l)) r in
  loop acc map


(* === remove === *)

(* std-lib *)
let rec remove x cmp = function
  | Empty -> Empty
  | Node(l, v, d, r, h) ->
      let c = cmp x v in
      if c = 0 then
        merge l r
      else if c < 0 then
        bal (remove x cmp l) v d r
      else
        bal l v d (remove x cmp r)

(* Bat *)
let remove x cmp map =
  let rec loop = function
  | Node (l, k, v, r, _) ->
      let c = cmp x k in
      if c = 0 then merge l r else
        if c < 0 then bal (loop l) k v r else bal l k v (loop r)
  | Empty -> Empty in
  loop map
