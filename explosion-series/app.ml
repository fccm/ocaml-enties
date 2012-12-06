(* the higher level logic is here *)

type new_round_func =
  score:int -> difficulty:float -> int * float

type t = {
  state : State.t;
  score : int;
  round : int;
  difficulty : float;
  new_round : new_round_func;
}

let init_app ~difficulty ~new_round =
  let state = State.init_state ~difficulty in
  { state; score = 0; round = 1; difficulty; new_round }

let scoring ~score ~clic =
  if clic = 0
  then score
  else score - ((abs score) / 2)

let user_clic app ~t ~clic ~pos =
  let state = State.user_expanded_ball app.state pos t in
  let score = scoring app.score clic in
  { app with state; score }

let at_exit app =
  Printf.printf "# went until round: %d\n%!" app.round

let user_infos app =
  Printf.sprintf "round: %d / credit: %d" app.round app.score

let step app ~clic ~t ~dt =
  match State.state_step app.state t dt app.score with
  | State.Continue (state, score) -> { app with state; score }, clic
  | State.Done score ->
      let score, difficulty = app.new_round score app.difficulty in
      if score < 0 then failwith "Loosed";
      { app with score; difficulty;
        round = app.round + 1;
        state = State.init_state difficulty;
      }, 0
