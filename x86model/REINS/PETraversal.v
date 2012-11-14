(* write a function to read some int_8's  *)
(* write a function and turn them into DWORDs *)
(* write a function that walks over the list of int_8's and initializes each type given in the PEFormat  *)
(* write a function that uses and operations to determine what characteristics a section has *)
Require Import PEFormat.

Definition parseWord (data : list BYTE) (n : nat) : WORD := 
	
.

Definition parseDoubleWord (data : list BYTE) (n : nat) : DWORD :=
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
