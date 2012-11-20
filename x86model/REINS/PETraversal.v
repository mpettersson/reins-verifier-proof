Require Import Coq.Lists.List.
Require Import PEFormat.
Require Import Bits.
Require Import Coq.ZArith.BinInt.
Require Import Coq.NArith.BinPos.
Require Import Coq.ZArith.Zdiv.

Open Scope vector_scope.

(*Notation " [ x , .. , y ] " := (cons x .. (cons y nil) ..).*)

Definition block_size : Z := Z_of_nat 3072.

Definition Z_to_nat (z : Z) : nat :=
    match z with
    | Z0 => 0
    | Zpos p => nat_of_P p
    | Zneg p => 0
    end.

Definition word_to_nat (w : WORD) : nat :=
    Z_to_nat (Word.unsigned w).

Definition dword_to_nat (w : DWORD) : nat :=
    Z_to_nat (Word.unsigned w).

Definition ptr_to_nat {A} (p : Ptr A) : nat :=
    match p with
    | ptr d _ => dword_to_nat d
    end.

Definition word_to_Z (w : WORD) : Z :=
    Word.unsigned w.

Definition dword_to_Z (w : DWORD) : Z :=
    Word.unsigned w.

Definition ptr_to_Z {A} (p : Ptr A) : Z :=
    match p with
    | ptr d _ => dword_to_Z d
    end.

Definition getChunk (data : list (list int8)) (z : Z) : list int8 :=
   nth (Z_to_nat (Zdiv z block_size)) data (cons (Word.repr 0) nil).

(* use to cast int8 as int16 *)
Definition int8_to_int16 (x : int8) : int16 :=
   Word.repr(Word.unsigned x)
.

(* takes two int16 (cast from int8) and turns into WORD *)
Definition bytes_to_word (msb : int16) (lsb : int16) : WORD :=
   Word.add (Word.mul msb (Word.repr 256)) lsb
.

Definition parseByte (data : list(list BYTE)) (z : Z) : BYTE :=
   let chunk := getChunk data z in
   let n := Z_to_nat (Zmod z block_size) in
   nth n chunk (Word.repr 0)
.

(* takes list of bytes and idx and returns a WORD *)
Definition parseWord (data : list (list BYTE)) (z : Z) : WORD := 
   let chunk := getChunk data z in
   let n := Z_to_nat (Zmod z block_size) in
   bytes_to_word (int8_to_int16 (nth (S n) chunk (Word.repr 0))) 
                 (int8_to_int16 (nth n chunk (Word.repr 0)))  
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
Definition parseDoubleWord (data : list (list BYTE)) (z : Z) : DWORD :=
   let chunk := getChunk data z in
   let n := Z_to_nat (Zmod z block_size) in
   bytes_to_dword (int8_to_int32 (nth (S (S (S n))) chunk (Word.repr 0)))
                  (int8_to_int32 (nth (S (S n)) chunk (Word.repr 0)))
                  (int8_to_int32 (nth (S n) chunk (Word.repr 0)))
                  (int8_to_int32 (nth n chunk (Word.repr 0)))
.

Definition parsePtr (data : list (list BYTE)) (z : Z) {A : Type} : Ptr A :=
   ptr (parseDoubleWord data z) A
.

Fixpoint parseVector {A : Type} (parse : list (list BYTE) -> Z -> A)
                                (data : list(list BYTE))
                                (size : Z)
                                (n : Z)
                                (count : nat)
                                 : vector count A :=
    match count with
    | 0 => []
    | S count' => (parse data n) :: (parseVector parse data size (n + size) count')
    end.

Definition parseImageDosHeader (data : list(list BYTE)) : _IMAGE_DOS_HEADER :=
 mkImageDosHeader 
   (parseWord data 0)   (* e_magic *)
   (parseWord data 2)   (* e_cblp *)
   (parseWord data 4)   (* e_cp *)
   (parseWord data 6)   (* e_crlc *)
   (parseWord data 8)   (* e_cparhdr *)
   (parseWord data 10)  (* e_minalloc *)
   (parseWord data 12)  (* e_maxalloc *)
   (parseWord data 14)  (* e_ss *)
   (parseWord data 16)  (* e_sp *)
   (parseWord data 18)  (* e_csum *)
   (parseWord data 20)  (* e_ip *)
   (parseWord data 22)  (* e_cs *)
   (parseWord data 24)  (* e_lfarlc *)
   (parseWord data 26)  (* e_ovno *)
   ((parseWord data 28)::
   (parseWord data 30)::
   (parseWord data 32)::
   (parseWord data 34)::[]) (* e_res *)
   (parseWord data 36)  (* e_oemid *)
   (parseWord data 38)  (* e_oeminfo *)
   ((parseWord data 40)::
   (parseWord data 42)::
   (parseWord data 44)::
   (parseWord data 46)::
   (parseWord data 48)::
   (parseWord data 50)::
   (parseWord data 52)::
   (parseWord data 54)::
   (parseWord data 56)::
   (parseWord data 58)::[]) (* e_res2 *)
   (parsePtr data 60) (* e_lfanew *)
.

Definition parseImageFileHeader (data : list (list BYTE)) (n : Z) : _IMAGE_FILE_HEADER :=
    mkImageFileHeader
      (parseWord data n)
      (parseWord data (n+2))
      (parseDoubleWord data (n+4))
      (parseDoubleWord data (n+8))
      (parseDoubleWord data (n+12))
      (parseWord data (n+16))
      (parseWord data (n+18))
.

Definition parseImageDataDirectory (data : list(list BYTE)) (n : Z) : _IMAGE_DATA_DIRECTORY :=
    mkImageDataDirectory
      (parseDoubleWord data n)
      (parseDoubleWord data (n + 4))
.

Definition parseImageOptionalHeader (data : list(list BYTE)) (n : Z) : _IMAGE_OPTIONAL_HEADER :=
    mkImageOptionalHeader
      (parseWord data n)
      (parseByte data (n + 2))
      (parseByte data (n + 3))
      (parseDoubleWord data (n + 4))
      (parseDoubleWord data (n + 8))
      (parseDoubleWord data (n + 12))
      (parseDoubleWord data (n + 16))
      (parseDoubleWord data (n + 20))
      (parseDoubleWord data (n + 24))
      (parseDoubleWord data (n + 28))
      (parseDoubleWord data (n + 32))
      (parseDoubleWord data (n + 36))
      (parseWord data (n + 40))
      (parseWord data (n + 42))
      (parseWord data (n + 44))
      (parseWord data (n + 46))
      (parseWord data (n + 48))
      (parseWord data (n + 50))
      (parseDoubleWord data (n + 52))
      (parseDoubleWord data (n + 56))
      (parseDoubleWord data (n + 60))
      (parseDoubleWord data (n + 64))
      (parseWord data (n + 68))
      (parseWord data (n + 70))
      (parseDoubleWord data (n + 72))
      (parseDoubleWord data (n + 76))
      (parseDoubleWord data (n + 80))
      (parseDoubleWord data (n + 84))
      (parseDoubleWord data (n + 88))
      (parseDoubleWord data (n + 92))
      (parseVector parseImageDataDirectory data 8 (n + 96) 16)
.

Definition parseImageNtHeader (data : list (list BYTE)) (n : Z) : _IMAGE_NT_HEADER :=
    mkImageNtHeader
      (parseDoubleWord data n)
      (parseImageFileHeader data (n + 4))
      (parseImageOptionalHeader data (n + 24))
.

Definition IMAGE_SIZEOF_SHORT_NAME : Z := Z_of_nat 8.

Definition parseImageSectionHeader (data : list (list BYTE)) (n : Z) : _IMAGE_SECTION_HEADER :=
    mkImageSectionHeader
        (parseVector (parseByte) data 1 n (Z_to_nat IMAGE_SIZEOF_SHORT_NAME))
        (parseDoubleWord data (n + IMAGE_SIZEOF_SHORT_NAME))
        (parseDoubleWord data (n + IMAGE_SIZEOF_SHORT_NAME + 4))
        (parseDoubleWord data (n + IMAGE_SIZEOF_SHORT_NAME + 8))
        (parseDoubleWord data (n + IMAGE_SIZEOF_SHORT_NAME + 12))
        (parseDoubleWord data (n + IMAGE_SIZEOF_SHORT_NAME + 16))
        (parseDoubleWord data (n + IMAGE_SIZEOF_SHORT_NAME + 20))
        (parseWord data (n + IMAGE_SIZEOF_SHORT_NAME + 24))
        (parseWord data (n + IMAGE_SIZEOF_SHORT_NAME + 26))
        (parseDoubleWord data (n + IMAGE_SIZEOF_SHORT_NAME + 28))
.

Definition parseImageExportDirectory (data : list (list BYTE)) (n : Z) : _IMAGE_EXPORT_DIRECTORY :=
    mkImageExportDirectory
      (parseDoubleWord data n)
      (parseDoubleWord data (n+4))
      (parseWord data (n+8))
      (parseWord data (n+10))
      (parseDoubleWord data (n+12))
      (parseDoubleWord data (n+16))
      (parseDoubleWord data (n+20))
      (parseDoubleWord data (n+24))
      (parseDoubleWord data (n+28))
      (parseDoubleWord data (n+32))
      (parseDoubleWord data (n+36))
.

Fixpoint findSection (data : list (list BYTE)) (rva : DWORD) (n : Z) (num_sec : nat) : option _IMAGE_SECTION_HEADER :=
    match num_sec with
    | 0 => None
    | S n' => let curSection := parseImageSectionHeader data n in
              let v_start := VirtualAddress_ISH curSection in
              let v_end := Word.add v_start (SizeOfRawData curSection) in
              if andb (Word.lequ v_start rva) (Word.ltu rva v_end) then
                 Some curSection
              else
                 findSection data rva (n + 40) n'
    end.


Definition vAddr_to_offset (vaddr : DWORD) (header : _IMAGE_SECTION_HEADER) : DWORD :=
    Word.add (Word.sub vaddr (VirtualAddress_ISH header)) (PointerToRawData header).


Definition derefImageNtHeader (data : list (list BYTE)) (p : Ptr _IMAGE_NT_HEADER) : _IMAGE_NT_HEADER :=
        match p with
        | ptr d _ => parseImageNtHeader data (Word.unsigned d)
        end.

Definition getExports (data : list (list BYTE)) : list DWORD :=
    let dosHeader := parseImageDosHeader data in
    let ntHeader := derefImageNtHeader data (e_lfanew dosHeader) in
    let rva := (VirtualAddress_IDD (nth 0 (vtolist (DataDirectory (OptionalHeader ntHeader)))
                                           {| VirtualAddress_IDD := Word.repr 0; Size := Word.repr 0 |})) in
    match Word.unsigned rva with
    | 0%Z => nil
    | _ =>
           let sectionHeader := findSection data rva
                               ((ptr_to_Z (e_lfanew dosHeader)) + 248)
                               (word_to_nat (NumberOfSections (FileHeader ntHeader))) in
           match sectionHeader with
           | None => nil
           | Some header =>
           let exportDir := parseImageExportDirectory data (dword_to_Z (vAddr_to_offset rva header)) in
               vtolist (parseVector (parseDoubleWord) data 4
                           (dword_to_Z (vAddr_to_offset (AddressOfFunctions exportDir) header))
                           (dword_to_nat (NumberOfFunctions exportDir)))
           end
    end.

(* given a file, check that all exported symbols target
*  low memory chunk boundaries *)
Definition checkExports (data : list (list BYTE)) (mask : DWORD) : bool :=
    let exports := getExports data in
    let check (addr : DWORD) : bool :=
        Word.eq addr (Word.and addr mask)
    in
    List.fold_left (andb) (List.map check exports) true
.

(*Definition parseImports :=
.

Fixpoint validateImports :=
.

Fixpoint validateExports :=
.

Definition parseSectionCharacteristics :=
.

Definition validateSection :=*)

Close Scope vector_scope.
