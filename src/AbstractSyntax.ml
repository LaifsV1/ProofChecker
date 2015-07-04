(* Abstract Syntax Trees - Syntax Grammar*)
(* author: Yu-Yang Lin *)

(* Variables *)
type var = string 

(* Types *)
type tp = Bool | Nat | List of tp | Arrow of tp * tp

(* Terms *)
type term = Var of var                 (*var*)
          | App of term * term         (*app*)
          | Boolean of bool            (*bool*)
          | Zero | Suc of term         (*nats*)
          | Nil  | Cons of term * term (*lists*)

(* Propositional Hypotheses *)
type prop = Truth | Falsity            (*top and bot*)
          | And of prop * prop         (*and*)
          | Or of prop * prop          (*or*)
          | Implies of prop * prop     (*implies*)
          | Eq of term * term * tp     (*eq*)
          | Forall of var * tp * prop  (*forall*)
          | Exists of var * tp * prop  (*exists*)

(* Term Context *)
type ctx = ( var * tp ) list

(* Propositions Context *)
type hyps = ( var * prop ) list

(* Proofs *)
type pf = AndL of (var * var) * var * pf        (*let (H',H'') = H in p*)
        | AndR of pf * pf                       (*p,q*)
        | OrL of var * (var * pf) * (var * pf)  (*match [H] with [H']:p | [H'']:q*)
        | OrR1 of pf                            (*A v B*)
        | OrR2 of pf                            (*A v B*)
        | ImpliesL of pf * (var * var) * pf     (*p, B [H'] via (A implies B) [H], q*)
        | ImpliesR of var * pf                  (*Assume [H], p*)
        | By of var                             (*by H*)
        | Therefore of pf * prop                (*p Therefore A*)
