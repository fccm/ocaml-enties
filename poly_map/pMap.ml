(*
  OCaml

  Xavier Leroy, projet Cristal, INRIA Rocquencourt

  Copyright 1996 Institut National de Recherche en Informatique et
  en Automatique.  All rights reserved.  This file is distributed
  under the terms of the GNU Library General Public License, with
  the special exception on linking described in file LICENSE:
  http://caml.inria.fr/cgi-bin/viewvc.cgi/ocaml/trunk/LICENSE?view=markup
*)

(*
   This module has been modified from the standard library to be
   polymorphic.
*)

type ('key, 'data) t =
  | Empty
  | Node of ('key, 'data) t * 'key * 'data * ('key, 'data) t * int

(*
let height = function
  | Empty -> 0
  | Node(_,_,_,_,h) -> h
*)
let height = function
  | Node(_,_,_,_,h) -> h
  | Empty -> 0

let create l x d r =
  let hl = height l and hr = height r in
  Node(l, x, d, r, (if hl >= hr then hl + 1 else hr + 1))

let singleton x d = Node(Empty, x, d, Empty, 1)

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
            Empty -> invalid_arg "Map.bal"
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

let empty = Empty

let is_empty = function Empty -> true | _ -> false

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

let rec find x cmp = function
  | Empty ->
      raise Not_found
  | Node(l, v, d, r, _) ->
      let c = cmp x v in
      if c = 0 then d
      else find x cmp (if c < 0 then l else r)

let rec find_opt x cmp = function
  | Empty -> None
  | Node(l, v, d, r, _) ->
      let c = cmp x v in
      if c = 0 then Some d
      else find_opt x cmp (if c < 0 then l else r)

let rec find_default x cmp def = function
  | Empty -> def
  | Node(l, v, d, r, _) ->
      let c = cmp x v in
      if c = 0 then d
      else find_default x cmp def (if c < 0 then l else r)

let rec mem x cmp = function
  | Empty ->
      false
  | Node(l, v, d, r, _) ->
      let c = cmp x v in
      c = 0 || mem x cmp (if c < 0 then l else r)

let rec min_binding = function
  | Empty -> raise Not_found
  | Node(Empty, x, d, r, _) -> (x, d)
  | Node(l, x, d, r, _) -> min_binding l

let rec max_binding = function
  | Empty -> raise Not_found
  | Node(l, x, d, Empty, _) -> (x, d)
  | Node(l, x, d, r, _) -> max_binding r

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

let rec remove x cmp = function
  | Empty ->
      Empty
  | Node(l, v, d, r, h) ->
      let c = cmp x v in
      if c = 0 then
        merge l r
      else if c < 0 then
        bal (remove x cmp l) v d r
      else
        bal l v d (remove x cmp r)

let rec iterk f = function
  | Empty -> ()
  | Node(l, v, d, r, _) ->
      iterk f l; f v d; iterk f r

let rec iter f = function
  | Empty -> ()
  | Node(l, _, d, r, _) ->
      iter f l; f d; iter f r

let rec map f = function
  | Empty ->
      Empty
  | Node(l, v, d, r, h) ->
      let l' = map f l in
      let d' = f d in
      let r' = map f r in
      Node(l', v, d', r', h)

let rec mapk f = function
  | Empty ->
      Empty
  | Node(l, v, d, r, h) ->
      let l' = mapk f l in
      let d' = f v d in
      let r' = mapk f r in
      Node(l', v, d', r', h)

let rec foldk f m accu =
  match m with
  | Empty -> accu
  | Node(l, v, d, r, _) ->
      foldk f r (f v d (foldk f l accu))

let rec fold f m accu =
  match m with
  | Empty -> accu
  | Node(l, _, d, r, _) ->
      fold f r (f d (fold f l accu))

let fold f m acc =
  let rec aux acc = function
  | Empty -> acc
  | Node (l, _, v, r, _) -> aux (f v (aux acc l)) r
  in
  aux acc m

let rec for_all p = function
  | Empty -> true
  | Node(l, v, d, r, _) -> p v d && for_all p l && for_all p r

let rec exists p = function
  | Empty -> false
  | Node(l, v, d, r, _) -> p v d || exists p l || exists p r

let filter p cmp s =
  let rec filt accu = function
    | Empty -> accu
    | Node(l, v, d, r, _) ->
        filt (filt (if p v d then add v d cmp accu else accu) l) r in
  filt Empty s

let partition p cmp s =
  let rec part (t, f as accu) = function
    | Empty -> accu
    | Node(l, v, d, r, _) ->
        part (part (if p v d then (add v d cmp t, f)
                             else (t, add v d cmp f)) l) r in
  part (Empty, Empty) s

(* Same as create and bal, but no assumptions are made on the
   relative heights of l and r. *)

let rec join cmp l v d r =
  match (l, r) with
  | (Empty, _) -> add v d cmp r
  | (_, Empty) -> add v d cmp l
  | (Node(ll, lv, ld, lr, lh), Node(rl, rv, rd, rr, rh)) ->
      if lh > rh + 2 then bal ll lv ld (join cmp lr v d r) else
      if rh > lh + 2 then bal (join cmp l v d rl) rv rd rr else
      create l v d r

(* Merge two trees l and r into one.
   All elements of l must precede the elements of r.
   No assumption on the heights of l and r. *)

let concat cmp t1 t2 =
  match (t1, t2) with
  | (Empty, t) -> t
  | (t, Empty) -> t
  | (_, _) ->
      let (x, d) = min_binding t2 in
      join cmp t1 x d (remove_min_binding t2)

let concat_or_join cmp t1 v d t2 =
  match d with
  | Some d -> join cmp t1 v d t2
  | None -> concat cmp t1 t2

let rec split cmp x = function
  | Empty ->
      (Empty, None, Empty)
  | Node(l, v, d, r, _) ->
      let c = cmp x v in
      if c = 0 then (l, Some d, r)
      else if c < 0 then
        let (ll, pres, rl) = split cmp x l in (ll, pres, join cmp rl v d r)
      else
        let (lr, pres, rr) = split cmp x r in (join cmp l v d lr, pres, rr)

let rec merge cmp f s1 s2 =
  match (s1, s2) with
  | (Empty, Empty) -> Empty
  | (Node (l1, v1, d1, r1, h1), _) when h1 >= height s2 ->
      let (l2, d2, r2) = split cmp v1 s2 in
      concat_or_join cmp (merge cmp f l1 l2) v1 (f v1 (Some d1) d2) (merge cmp f r1 r2)
  | (_, Node (l2, v2, d2, r2, h2)) ->
      let (l1, d1, r1) = split cmp v2 s1 in
      concat_or_join cmp (merge cmp f l1 l2) v2 (f v2 d1 (Some d2)) (merge cmp f r1 r2)
  | _ ->
      assert false

type ('key, 'a) enumeration =
  | End
  | More of 'key * 'a * ('key, 'a) t * ('key, 'a) enumeration

let rec cons_enum m e =
  match m with
  | Empty -> e
  | Node(l, v, d, r, _) -> cons_enum l (More(v, d, r, e))

let compare cmp m1 m2 compare =
  let rec compare_aux e1 e2 =
    match (e1, e2) with
    | (End, End) -> 0
    | (End, _)  -> -1
    | (_, End) -> 1
    | (More(v1, d1, r1, e1), More(v2, d2, r2, e2)) ->
        let c = compare v1 v2 in
        if c <> 0 then c else
        let c = cmp d1 d2 in
        if c <> 0 then c else
        compare_aux (cons_enum r1 e1) (cons_enum r2 e2)
  in compare_aux (cons_enum m1 End) (cons_enum m2 End)

let equal cmp m1 m2 compare =
  let rec equal_aux e1 e2 =
    match (e1, e2) with
    | (End, End) -> true
    | (End, _)  -> false
    | (_, End) -> false
    | (More(v1, d1, r1, e1), More(v2, d2, r2, e2)) ->
        compare v1 v2 = 0 && cmp d1 d2 &&
        equal_aux (cons_enum r1 e1) (cons_enum r2 e2)
  in equal_aux (cons_enum m1 End) (cons_enum m2 End)

let rec cardinal = function
  | Empty -> 0
  | Node(l, _, _, r, _) -> cardinal l + 1 + cardinal r

let rec bindings_aux accu = function
  | Empty -> accu
  | Node(l, v, d, r, _) -> bindings_aux ((v, d) :: bindings_aux accu r) l

let bindings s =
  bindings_aux [] s

let rec values_aux accu = function
  | Empty -> accu
  | Node(l, _, d, r, _) -> values_aux (d :: values_aux accu r) l

let values s =
  values_aux [] s

let rec keys_aux accu = function
  | Empty -> accu
  | Node(l, v, _, r, _) -> keys_aux (v :: keys_aux accu r) l

let keys s =
  keys_aux [] s

let choose = min_binding
