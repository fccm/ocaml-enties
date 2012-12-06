type id = int
external c2i : 'a -> int = "%identity"
val cmp_comp : 'a -> 'b -> int
val cmp_e : int -> int -> int
val not_int : 'a -> bool
type ('component_type, 'component) entity = {
  id : id;
  components : ('component_type, 'component) PMap.t;
}
val new_entity : unit -> ('a, 'b) entity
val get_id_opt : ('a, 'b) entity -> id option
val get_id : ('a, 'b) entity -> id
val has_component : ('a, 'b) entity -> 'a -> bool
val has_components : ('a, 'b) entity -> 'a list -> bool
val has_any_component : ('a, 'b) entity -> 'a list -> bool
val put_component : ('a, 'b) entity -> 'a * 'b -> ('a, 'b) entity
val add_component : ('a, 'b) entity -> 'a * 'b -> ('a, 'b) entity
val replace_component : ('a, 'b) entity -> 'a -> 'b -> ('a, 'b) entity
val get_component : ('a, 'b) entity -> 'a -> 'b
val get_component_opt : ('a, 'b) entity -> 'a -> 'b option
val remove_component : ('a, 'b) entity -> 'a -> ('a, 'b) entity
val iter_components : ('a, 'b) entity -> ('a -> 'b -> unit) -> unit
val get_components : ('a, 'b) entity -> 'a list
val cmp_components : ('a, 'b) entity -> 'a list -> int
val components_match : ('a, 'b) entity -> 'a list -> bool
type 'comp_t mapper = { comp_t : 'comp_t list; }
val make_mapper : 'a list -> 'a mapper
val mapper_match : ('a, 'b) entity -> 'a mapper -> bool
type ('a, 'b) world = {
  id_counter : int;
  entities : (id, ('a, 'b) entity) PMap.t;
  mappers : 'a mapper list;
}
val new_world : unit -> ('a, 'b) world
val add_entity : ('a, 'b) world -> ('a, 'b) entity -> ('a, 'b) world
val add_entity_id : ('a, 'b) world -> ('a, 'b) entity -> ('a, 'b) world * int
val remove_entity : ('a, 'b) world -> ('c, 'd) entity -> ('a, 'b) world
val remove_entity_id : ('a, 'b) world -> id -> ('a, 'b) world
val get_entity : ('a, 'b) world -> id -> ('a, 'b) entity
val get_entity_opt : ('a, 'b) world -> id -> ('a, 'b) entity option
val num_entities : ('a, 'b) world -> int
val has_entity : ('a, 'b) world -> id -> bool
val iter_entities : (('a, 'b) entity -> unit) -> ('a, 'b) world -> unit
val fold_entities :
  (('a, 'b) entity -> 'c -> 'c) -> ('a, 'b) world -> 'c -> 'c
val add_entities : ('a, 'b) world -> ('a, 'b) entity list -> ('a, 'b) world
val add_entities_ar :
  ('a, 'b) world -> ('a, 'b) entity array -> ('a, 'b) world
val add_entities_init :
  w:('a, 'b) world -> n:int -> f:(int -> ('a, 'b) entity) -> ('a, 'b) world
val _add_entities_id :
  ('a, 'b) world -> ('a, 'b) entity list -> ('a, 'b) world * int list
val add_entities_id :
  ('a, 'b) world -> ('a, 'b) entity list -> ('a, 'b) world * int list
val add_entities_id_ar :
  ('a, 'b) world -> ('a, 'b) entity array -> ('a, 'b) world * int array
val put_entity : ('a, 'b) world -> id -> ('a, 'b) entity -> ('a, 'b) world
val replace_entity :
  ('a, 'b) world -> id -> ('a, 'b) entity -> ('a, 'b) world
val num_entities_with_components : ('a, 'b) world -> 'a list -> int
val get_entities_with_components :
  ('a, 'b) world -> 'a list -> ('a, 'b) entity list
val get_entities : ('a, 'b) world -> id list -> ('a, 'b) entity list
val do_get_entities : ('a, 'b) world -> id list -> ('a, 'b) entity list
type 'a update = Identic | Updated of 'a | Replace of 'a | Removed
type ('comp_t, 'comp, 'fld) born_feedback_func =
    ('comp_t, 'comp) world ->
    ('comp_t, 'comp) entity ->
    id list -> 'fld -> ('comp_t, 'comp) world * 'fld
val world_fold :
  ('a, 'b) world ->
  'a mapper ->
  (('a, 'b) entity ->
   ('a, 'b) world ->
   'c -> 'd -> ('a, 'b) entity update * ('a, 'b) entity list) ->
  ?fb:(('a, 'b) world ->
       ('a, 'b) entity -> int list -> 'd -> ('a, 'b) world * 'd) ->
  'c -> 'd -> ('a, 'b) world * 'd
