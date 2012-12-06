(*
  OCaml

  Xavier Leroy, projet Cristal, INRIA Rocquencourt

  Copyright 1996 Institut National de Recherche en Informatique et
  en Automatique.  All rights reserved.  This file is distributed
  under the terms of the GNU Library General Public License, with
  the special exception on linking described in file LICENSE:
  http://caml.inria.fr/cgi-bin/viewvc.cgi/ocaml/trunk/LICENSE?view=markup
*)

(** Association tables over ordered types.

   This module implements applicative association tables, also known as
   finite maps or dictionaries, given a total ordering function
   over the keys.
   All operations over maps are purely applicative (no side-effects).
   The implementation uses balanced binary trees, and therefore searching
   and insertion take time logarithmic in the size of the map.

   This module has been modified from the standard library to be
   polymorphic.
*)

type ('key, 'data) t
(** The type of maps from type ['key] to type ['data]. *)

val empty: ('key, 'data) t
(** The empty map. *)

val is_empty: ('key, 'data) t -> bool
(** Test whether a map is empty or not. *)

val add: 'key -> 'data ->
  ('key -> 'key -> int) ->
  ('key, 'data) t -> ('key, 'data) t
(** [add x y cmp m] returns a map containing the same bindings as
    [m], plus a binding of [x] to [y]. If [x] was already bound
    in [m], its previous binding disappears.
    [cmp] compares keys. *)

val singleton: 'key -> 'data -> ('key, 'data) t
(** [singleton x y] returns the one-element map that contains a binding [y]
    for [x]. *)

val remove: 'key -> ('key -> 'key -> int) -> ('key, 'data) t -> ('key, 'data) t
(** [remove x m] returns a map containing the same bindings as
    [m], except for [x] which is unbound in the returned map. *)

val merge :
  ('key -> 'key -> int) ->
  ('key -> 'a option -> 'b option -> 'c option) ->
  ('key, 'a) t ->
  ('key, 'b) t ->
  ('key, 'c) t
(** [merge cmp f m1 m2] computes a map whose keys is a subset of keys of [m1]
    and of [m2]. The presence of each such binding, and the corresponding
    value, is determined with the function [f]. *)


(** {6 Comparing} *)

val compare:
  ('data -> 'data -> int) ->
  ('key, 'data) t ->
  ('key, 'data) t ->
  ('key -> 'key -> int) ->
  int
(** Total ordering between maps.  The first argument is a total ordering
    used to compare data associated with equal keys in the two maps. *)

val equal:
  ('data -> 'data -> bool) ->
  ('key, 'data) t ->
  ('key, 'data) t ->
  ('key -> 'key -> int) ->
  bool
(** [equal comp_data m1 m2 comp_key] tests whether the maps [m1] and [m2]
    are equal, that is, contain equal keys and associate them with
    equal data.  [cmp] is the equality predicate used to compare
    the data associated with the keys. *)


(** {6 Access} *)

val cardinal: ('key, 'data) t -> int
(** Return the number of bindings of a map. *)

val bindings: ('key, 'data) t -> ('key * 'data) list
(** Return the list of all bindings of the given map.
    The returned list is sorted in increasing order with respect
    to the ordering from [('key -> 'key -> int)]. *)

val keys: ('key, 'data) t -> 'key list
(** Return the list of all keys of the given map.
    The returned list is sorted in increasing order with respect
    to the ordering from [('key -> 'key -> int)]. *)

val values: ('key, 'data) t -> 'data list
(** Return the list of all values of the given map.
    The returned list is sorted in increasing order with respect
    to the ordering from [('key -> 'key -> int)]. *)

val min_binding: ('key, 'data) t -> ('key * 'data)
(** Return the smallest binding of the given map
    (with respect to the [('key -> 'key -> int)] ordering), or raise
    [Not_found] if the map is empty. *)

val max_binding: ('key, 'data) t -> ('key * 'data)
(** Same as [min_binding], but returns the largest binding
    of the given map. *)

val choose: ('key, 'data) t -> ('key * 'data)
(** Return one binding of the given map, or raise [Not_found] if
    the map is empty. Which binding is chosen is unspecified,
    but equal bindings will be chosen for equal maps. *)


(** {6 Iterators} *)

val iter: ('data -> unit) -> ('key, 'data) t -> unit
val iterk: ('key -> 'data -> unit) -> ('key, 'data) t -> unit
(** [iter f m] applies [f] to all bindings in map [m].
    [f] receives the key as first argument, and the associated value
    as second argument.  The bindings are passed to [f] in increasing
    order with respect to the ordering over the type of the keys. *)

val fold: ('data -> 'acc -> 'acc) -> ('key, 'data) t -> 'acc -> 'acc
val foldk: ('key -> 'data -> 'acc -> 'acc) -> ('key, 'data) t -> 'acc -> 'acc
(** [fold f m a] computes [(f kN dN ... (f k1 d1 a)...)],
   where [k1 ... kN] are the keys of all bindings in [m]
   (in increasing order), and [d1 ... dN] are the associated data. *)

val map: ('data_a -> 'data_b) -> ('key, 'data_a) t -> ('key, 'data_b) t
(** [map f m] returns a map with same domain as [m], where the
    associated value [a] of all bindings of [m] has been
    replaced by the result of the application of [f] to [a].
    The bindings are passed to [f] in increasing order
    with respect to the ordering over the type of the keys. *)

val mapk: ('key -> 'data_a -> 'data_b) -> ('key, 'data_a) t -> ('key, 'data_b) t
(** Same as [map], but the function receives as arguments both the
    key and the associated value for each binding of the map. *)


(** {6 Map scanning} *)

val for_all: ('key -> 'data -> bool) -> ('key, 'data) t -> bool
(** [for_all p m] checks if all the bindings of the map
    satisfy the predicate [p]. *)

val exists: ('key -> 'data -> bool) -> ('key, 'data) t -> bool
(** [exists p m] checks if at least one binding of the map
    satisfy the predicate [p]. *)

val mem: 'key -> ('key -> 'key -> int) -> ('key, 'data) t -> bool
(** [mem x m] returns [true] if [m] contains a binding for [x],
    and [false] otherwise. *)


(** {6 Map searching} *)

val find: 'key -> ('key -> 'key -> int) -> ('key, 'data) t -> 'data
(** [find x m] returns the current binding of [x] in [m],
    or raises [Not_found] if no such binding exists. *)

val find_opt: 'key -> ('key -> 'key -> int) -> ('key, 'data) t -> 'data option
(** [find x m] returns the current binding of [x] in [m],
    if any. *)

val find_default: 'key -> ('key -> 'key -> int) -> 'data -> ('key, 'data) t -> 'data
(** [find x m] returns the current binding of [x] in [m],
    or a default value if nothing found. *)

val filter:
  ('key -> 'data -> bool) ->
  ('key -> 'key -> int) ->
  ('key, 'data) t ->
  ('key, 'data) t
(** [filter p m] returns the map with all the bindings in [m]
    that satisfy predicate [p]. *)

val partition:
  ('key -> 'data -> bool) ->
  ('key -> 'key -> int) ->
  ('key, 'data) t ->
  ('key, 'data) t * ('key, 'data) t
(** [partition p m] returns a pair of maps [(m1, m2)], where
    [m1] contains all the bindings of [s] that satisfy the
    predicate [p], and [m2] is the map with all the bindings of
    [s] that do not satisfy [p]. *)

val split:
  ('key -> 'key -> int) ->
  'key ->
  ('key, 'data) t ->
  ('key, 'data) t * 'data option * ('key, 'data) t
(** [split x m] returns a triple [(l, data, r)], where
      [l] is the map with all the bindings of [m] whose key
    is strictly less than [x];
      [r] is the map with all the bindings of [m] whose key
    is strictly greater than [x];
      [data] is [None] if [m] contains no binding for [x],
      or [Some v] if [m] binds [v] to [x]. *)
