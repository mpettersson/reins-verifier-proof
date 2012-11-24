Require Import Coq.Lists.List.
Require Import ZArith.
Require Import Bits.
Require Import PETraversal.
Require Import ReinsVerifierDFA.
Require Import ReinsVerifier.
Require Import Parser.
Require Import X86Syntax.
Require Import Decode.

Import X86_PARSER_ARG.
Import X86_PARSER.
Import X86_BASE_PARSER.



Notation " [ x , .. , y ] " := (List.cons x .. (List.cons y List.nil) ..).
Open Scope nat_scope.

Set Printing Depth 10000.

Time Compute (make_dfa reinsjmp_nonIAT_mask).
Time Compute (make_dfa reinsjmp_IAT_or_RET_mask).
Time Compute (make_dfa dir_cflow_parser).
Time Compute (make_dfa non_cflow_parser).
