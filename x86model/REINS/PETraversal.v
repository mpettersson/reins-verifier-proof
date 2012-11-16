(* write a function to read some int_8's  *)
(* write a function and turn them into DWORDs *)
(* write a function that walks over the list of int_8's and initializes each type given in the PEFormat  *)
(* write a function that uses and operations to determine what characteristics a section has *)
Require Import PEFormat.
Require Import out.
Require Import Coq.Lists.List.
Require Import Bits.


(* use to cast int8 as int16 *)
Definition int8_to_int16 (x : int8) : int16 :=
   Word.repr(Word.unsigned(x))
.

(* takes two int16 (cast from int8) and turns into WORD *)
Definition bytes_to_word (msb : int16) (lsb : int16) : WORD :=
   Word.add (Word.mul msb (Word.repr(256))) lsb
.

(* takes list of bytes and idx and returns a WORD *)
Definition parseWord (data : list BYTE) (n : nat) : WORD := 
   bytes_to_word (int8_to_int16 (nth n data (Word.repr(0)))) 
                 (int8_to_int16 (nth (S n) data (Word.repr(0))))  
.

(* use to cast int8 as int32 *)
Definition int8_to_int32 (x : int8) : int32 :=
   Word.repr(Word.unsigned(x))
.

(* takes four int32 (cast from int8) and turns into a DWORD *)
Definition bytes_to_dword (w : int32) (x : int32) 
                          (y : int32) (z : int32) 
                          : DWORD :=
   Word.add
      (Word.add (Word.mul w (Word.repr 16777216)) 
                (Word.mul x (Word.repr 65536)))
      (Word.add (Word.mul y (Word.repr 256)) z)
.

(* returns DWORD at idx *)
Definition parseDoubleWord (data : list BYTE) (n : nat) : DWORD :=
   bytes_to_dword (int8_to_int32 (nth n data (Word.repr(0))))
                  (int8_to_int32 (nth (S n) data (Word.repr(0))))
                  (int8_to_int32 (nth (S (S n)) data (Word.repr(0))))
                  (int8_to_int32 (nth (S (S (S n))) data (Word.repr(0))))
.

Definition initImageDosHeader :=
 mkImageDosHeader 
   (parseWord bytes 0)   (* e_magic *)
   (parseWord bytes 2)   (* e_cblp *)
   (parseWord bytes 4)   (* e_cp *)
   (parseWord bytes 6)   (* e_crlc *)
   (parseWord bytes 8)   (* e_cparhdr *)
   (parseWord bytes 10)  (* e_minalloc *)
   (parseWord bytes 12)  (* e_maxalloc *)
   (parseWord bytes 14)  (* e_ss *)
   (parseWord bytes 16)  (* e_sp *)
   (parseWord bytes 18)  (* e_csum *)
   (parseWord bytes 20)  (* e_ip *)
   (parseWord bytes 22)  (* e_cs *)
   (parseWord bytes 24)  (* e_lfarlc *)
   (parseWord bytes 26)  (* e_ovno *)
   (* How to make a vector? *)
. 

Definition init := 
.

Definition initImageDosHeader :=
.

Definition initFileHeader :=
.

Fixpoint initOptionalHeader :=
.

Fixpoint initSectionHeader :=
.

Fixpoint initImports :=
.

Fixpoint validateImports :=
.

Fixpoint validateExports :=
.

Definition parseSectionCharacteristics :=
.

Definition validateSection :=
