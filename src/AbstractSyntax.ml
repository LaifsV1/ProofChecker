(* Abstract Syntax Trees - Syntax Grammar *)
(* author: Yu-Yang Lin *)

(* Position Data *)
type pos_range = (Lexing.position * Lexing.position)

(* Variables *)
type var = string

(* Types *)
type tp = Bool | Nat | List of tp | Arrow of tp * tp

(* Terms *)
(* f ( c_0 , ... , c_k ) where c_i : term *)
type term' = Var of var                  (*var*)
           | App of term * term          (*app*)
           | Boolean of bool             (*bool*)
           | Zero | Suc of term          (*nats*)
           | Nil  | Cons of term * term  (*lists*)
and term = pos_range * term'

(* no position term *)
type npTerm = Var of var                      (*var*)
            | App of npTerm * npTerm          (*app*)
            | Boolean of bool                 (*bool*)
            | Zero | Suc of npTerm            (*nats*)
            | Nil  | Cons of npTerm * npTerm  (*lists*)

(* Propositional Hypotheses *)
type prop' = Truth | Falsity            (*top and bot*)
           | And of prop * prop         (*and*)
           | Or of prop * prop          (*or*)
           | Implies of prop * prop     (*implies*)
           | Eq of term * term * tp     (*eq*)
           | Forall of var * tp * prop  (*forall*)
           | Exists of var * tp * prop  (*exists*)
and prop = pos_range * prop'

(* no position prop *)
type npProp = Truth | Falsity              (*top and bot*)
            | And of npProp * npProp       (*and*)
            | Or of npProp * npProp        (*or*)
            | Implies of npProp * npProp   (*implies*)
            | Eq of npTerm * npTerm * tp   (*eq*)
            | Forall of var * tp * npProp  (*forall*)
            | Exists of var * tp * npProp  (*exists*)

(* Spines *)
type spine_arg = SpineT of term | SpineH of var
type spine = spine_arg list

(* Term Context *)
type ctx = ( var * tp ) list

(* Hypotheses Labels *)
type hvar = var * (prop option)

(* Propositions Context *)
type hyps = ( var * prop ) list

(* Proofs *)
type pf' = TruthR                                  (*Truth-R,  T : A*) (***SPF***)
         | FalsityL of hvar                        (*Falsity-L, Absurd [H] : A*)
         | AndL of (hvar * hvar) * hvar * pf       (*let (H',H'') = H in p*)
         | AndR of pf * pf                         (*p,q*) (***SPF***)
         | OrL of hvar * (hvar * pf) * (hvar * pf) (*match [H] with [H']:p | [H'']:q*)
         | OrR1 of pf                              (*Left  p : A v B*) (***SPF***)
         | OrR2 of pf                              (*Right q : A v B*) (***SPF***)
         | ImpliesL of pf * (hvar * hvar) * pf     (*p, [H'] : B via [H] : (A => B), q*)
         | ImpliesR of hvar * pf                   (*Assume [H] : A, p*)
         | By of hvar                              (*by [H]*) (***SPF***)
         | Therefore of pf * prop                  (*p Therefore A*)
         | ExistsR of term * pf                    (*choose t, p*)
         | ExistsL of (var * hvar) * hvar * pf     (*let (x',H') = H in p*)
         | ForallR of (var * tp) * pf              (*Assume x:tau . p*)
         | ForallL of hvar * hvar * term * pf      (*let H' = H with t in p*)
         | ByIndNat  of pf * (var * hvar * pf)     (*ByInduction:case zero p;case suc(n),H,q*)
         | ByIndList of pf * ((var*var)*hvar*pf)   (*ByInduction:case nil p;case cons(y,ys),H,q*)
         | ByIndBool of pf * pf                    (*ByInduction:case true p;case false q*)
         | ByEq of hvar list                       (*By Equality [H_i]*)
         | HypLabel of var * prop * pf * pf        (*We know [H] : A because spf , p*)
         | SpineApp of hvar * spine                (*[H] with s*) (***SPF***)
and pf = pos_range * pf'

(* Monadic Errors *)
type 'a result = Ok of 'a | Wrong of pos_range

(* Monadic Operations *)
let return x = Ok x
let (>>=) x f =
  match x with
  | Ok v    -> f v
  | Wrong e -> Wrong e
let (>>) x y = x >>= (fun _ -> y)

(* TO STRING FUNCTIONS *)
let rec toString_tp (tau : tp) :(string) =
  match tau with
  | Bool -> "bool"
  | Nat  -> "nat"
  | List  x -> "[" ^ (toString_tp x) ^ "]"
  | Arrow (a,b)-> "(" ^ (toString_tp a) ^"->" ^ (toString_tp b) ^ ")"

let rec toString (t : npTerm) :(string) =
  match t with
  | Var x     -> "Var(\""^x^"\")"
  | App (f,x) -> "App("^(toString f)^","^(toString x)^")"
  | Boolean true -> "Boolean(true)"
  | Boolean false -> "Boolean(false)"
  | Zero          -> "Zero"
  | Suc n         -> "Suc("^(toString n)^")"
  | Nil           -> "Nil"
  | Cons (x,xs)   -> "Cons("^(toString x)^","^(toString xs)^")"


(* TopLevel Syntax *)
type toplevel = Sig of ctx | Def of hyps | Theorem of var * pf * prop
type proof_file = toplevel list
type proof_pair = (ctx * hyps) * proof_file
