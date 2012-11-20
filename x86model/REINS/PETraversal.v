(* TODO need to find out the size of LPBYTE in order to correctly observe 
Image Thunk Data structures and others... *)

Require Import Coq.Lists.List.
Require Import PEFormat.
Require Import Bits.
Require Import Coq.ZArith.BinInt.
Require Import Coq.NArith.BinPos.

Open Scope vector_scope.

(* use to cast int8 as int16 *)
Definition int8_to_int16 (x : int8) : int16 :=
   Word.repr(Word.unsigned(x))
.

(* takes two int16 (cast from int8) and turns into WORD *)
Definition bytes_to_word (msb : int16) (lsb : int16) : WORD :=
   Word.add (Word.mul msb (Word.repr(256))) lsb
.

Definition parseByte (data : list BYTE) (n : nat) : BYTE :=
    nth n data (Word.repr 0)
.

(* takes list of bytes and idx and returns a WORD *)
Definition parseWord (data : list BYTE) (n : nat) : WORD := 
   bytes_to_word (int8_to_int16 (nth (S n) data (Word.repr 0))) 
                 (int8_to_int16 (nth n data (Word.repr 0)))  
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

(* returns DWORD at idx *)
Definition parseDoubleWord (data : list BYTE) (n : nat) : DWORD :=
   bytes_to_dword (int8_to_int32 (nth (S (S (S n))) data (Word.repr(0))))
                  (int8_to_int32 (nth (S (S n)) data (Word.repr(0))))
                  (int8_to_int32 (nth (S n) data (Word.repr(0))))
                  (int8_to_int32 (nth n data (Word.repr(0))))
.

Definition parsePtr (data : list BYTE) (n : nat) {A : Type} : Ptr A :=
        ptr (parseDoubleWord data n) A
.

Fixpoint parseVector {A : Type} (parse : list BYTE -> nat -> A)
                                (data : list BYTE)
                                (size : nat)
                                (n : nat)
                                (count : nat)
                                 : vector count A :=
    match count with
    | 0 => []
    | S count' => (parse data n) :: (parseVector parse data size (n + size) count')
    end.

Definition parseImageDosHeader (data : list BYTE) : _IMAGE_DOS_HEADER :=
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

Definition parseImageFileHeader (data : list BYTE) (n : nat) : _IMAGE_FILE_HEADER :=
    mkImageFileHeader
      (parseWord data n) 		(* Machine *)
      (parseWord data (n+2)) 		(* NumberOfSections *)
      (parseDoubleWord data (n+4)) 	(* TimeDateStamp_IFH *)
      (parseDoubleWord data (n+8)) 	(* PointerToSymbolTable *)
      (parseDoubleWord data (n+12)) 	(* NumberOfSymbols *)
      (parseWord data (n+16)) 		(* SizeOfOptionalHeader *)
      (parseWord data (n+18)) 		(* Characteristics_IFH *)
.

Definition parseImageDataDirectory (data : list BYTE) (n : nat) : _IMAGE_DATA_DIRECTORY :=
    mkImageDataDirectory
      (parseDoubleWord data n)		(* VirtualAddress_IDD *)
      (parseDoubleWord data (n + 4)) 	(* Size *)
.

Definition parseImageOptionalHeader (data : list BYTE) (n : nat) : _IMAGE_OPTIONAL_HEADER :=
    mkImageOptionalHeader
      (parseWord data n)			(*Magic *)
      (parseByte data (n + 2))			(*MajorLinkerVersion *)
      (parseByte data (n + 3))			(*MinorLinkerVersion *)
      (parseDoubleWord data (n + 4))		(*SizeOfCode *)
      (parseDoubleWord data (n + 8))		(*SizeOfInitializedData *)
      (parseDoubleWord data (n + 12))		(*SizeOfUninitializedData *)
      (parseDoubleWord data (n + 16))		(*AddressOfEntryPoint *)
      (parseDoubleWord data (n + 20))		(*BaseOfCode *)
      (parseDoubleWord data (n + 24))		(*BaseOfData *)
      (parseDoubleWord data (n + 28))		(*ImageBase *)
      (parseDoubleWord data (n + 32))		(*SectionAlignment *)
      (parseDoubleWord data (n + 36))		(*FileAlignment *)
      (parseWord data (n + 40))			(*MajorOperatingSystemVersion *)
      (parseWord data (n + 42))			(*MinorOperatingSystemVersion *)
      (parseWord data (n + 44))			(*MajorImageVersion *)
      (parseWord data (n + 46))			(*MinorImageVersion *)
      (parseWord data (n + 48))			(*MajorSubsystemVersion *)
      (parseWord data (n + 50))			(*MinorSubsystemVersion *)
      (parseDoubleWord data (n + 52))		(*Win32VersionValue *)
      (parseDoubleWord data (n + 56))		(*SizeOfImage *)
      (parseDoubleWord data (n + 60))		(*SizeOfHeaders *)
      (parseDoubleWord data (n + 64))		(*CheckSum *)
      (parseWord data (n + 68))			(*Subsystem *)
      (parseWord data (n + 70))			(*DllCharacteristics *)
      (parseDoubleWord data (n + 72))		(*SizeOfStackReserve *)
      (parseDoubleWord data (n + 76))		(*SizeOfStackCommit *)
      (parseDoubleWord data (n + 80))		(*SizeOfHeapReserve *)
      (parseDoubleWord data (n + 84))		(*SizeOfHeapCommit *)
      (parseDoubleWord data (n + 88))		(*LoaderFlags *)
      (parseDoubleWord data (n + 92))		(*NumberOfRvaAndSizes *)
      (parseVector (parseImageDataDirectory) data 8 (n + 96) 16)(*DataDirectory *)
.

Definition parseImageNtHeader (data : list BYTE) (n : nat) : _IMAGE_NT_HEADER :=
    mkImageNtHeader
      (parseDoubleWord data n) 			(*Signature  *)
      (parseImageFileHeader data (n + 4)) 	(*FileHeader  *)
      (parseImageOptionalHeader data (n + 24)) 	(*OptionalHeader  *)
.


Definition parseImageSectionHeader (data : list BYTE) (n : nat) : _IMAGE_SECTION_HEADER :=
    mkImageSectionHeader
      (parseVector (parseByte) data 1 n IMAGE_SIZEOF_SHORT_NAME)(*Name_ISH *)
      (parseDoubleWord data (n + IMAGE_SIZEOF_SHORT_NAME))	(*PhysicalAddressORVirtualSize*)
      (parseDoubleWord data (n + IMAGE_SIZEOF_SHORT_NAME + 4))	(*VirtualAddress_ISH *)
      (parseDoubleWord data (n + IMAGE_SIZEOF_SHORT_NAME + 8))	(*SizeOfRawData *)
      (parseDoubleWord data (n + IMAGE_SIZEOF_SHORT_NAME + 12))	(*PointerToRawData *)
      (parseDoubleWord data (n + IMAGE_SIZEOF_SHORT_NAME + 16))	(*PointerToRelocations *)
      (parseDoubleWord data (n + IMAGE_SIZEOF_SHORT_NAME + 20))	(*PointerToLinenumbers *)
      (parseWord data (n + IMAGE_SIZEOF_SHORT_NAME + 24))	(*NumberOfRelocations *)
      (parseWord data (n + IMAGE_SIZEOF_SHORT_NAME + 26))	(*NumberOfLinenumbers *)
      (parseDoubleWord data (n + IMAGE_SIZEOF_SHORT_NAME + 28))	(*Characteristics_ISH *)
.


Definition parseImageExportDirectory (data : list BYTE) (n : nat) : _IMAGE_EXPORT_DIRECTORY :=
    mkImageExportDirectory
      (parseDoubleWord data n)		(*Characteristics_IED *)
      (parseDoubleWord data (n+4))	(*TimeDateStamp *)
      (parseWord data (n+8))		(*MajorVersion *)
      (parseWord data (n+10))		(*MinorVersion *)
      (parseDoubleWord data (n+12))	(*Name_IED *)
      (parseDoubleWord data (n+16))	(*Base *)
      (parseDoubleWord data (n+20))	(*NumberOfFunctions *)
      (parseDoubleWord data (n+24))	(*NumberOfNames *)
      (parseDoubleWord data (n+28))	(*AddressOfFunctions *)
      (parseDoubleWord data (n+32))	(*AddressOfNames *)
      (parseDoubleWord data (n+36))	(*AddressOfNameOrdinals *)
.

Definition parseImageThunkData (data : list BYTE) (n : nat) : _IMAGE_THUNK_DATA :=
    mkImageThunkData
    	(parseByte data n)		(*ForwarderString *)
	(parsePtr data (n+1)) 	(*Function *)
	(parseDoubleWord data (n+5))	(*Ordinal *)
	(parsePtr data (n+9))	(*AddressOfData *)
.

(* Adding a blankSectionHeader to return when one doesn't exist *)
Definition z : int8 := Word.repr 0.
Definition w : int16 := Word.repr 0.
Definition d : int32 := Word.repr 0.

Definition blankSectionHeader : _IMAGE_SECTION_HEADER :=
  mkImageSectionHeader
   (z::z::z::z::z::z::z::z::[])
   d d d d d d w w d.

Fixpoint findSection (data : list BYTE) (rva : DWORD) (n : nat) (num_sec : nat) : _IMAGE_SECTION_HEADER :=
    match num_sec with
    | 0 => blankSectionHeader
    | S n' => let curSection := parseImageSectionHeader data n in
              let v_start := VirtualAddress_ISH curSection in
              let v_end := Word.add v_start (SizeOfRawData curSection) in
              if andb (Word.lequ v_start rva) (Word.ltu rva v_end) then
                 curSection
              else
                 findSection data rva (n + 40) n'
    end.


Definition vAddr_to_offset (vaddr : DWORD) (header : _IMAGE_SECTION_HEADER) : DWORD :=
    Word.add (Word.sub vaddr (VirtualAddress_ISH header)) (PointerToRawData header).


Definition derefImageNtHeader (data : list BYTE) (p : Ptr _IMAGE_NT_HEADER) : _IMAGE_NT_HEADER :=
        match p with
        | ptr d _ => parseImageNtHeader data (dword_to_nat d)
        end.

Definition getExports (data : list BYTE) : list DWORD :=
    let dosHeader := parseImageDosHeader data in
    let ntHeader := derefImageNtHeader data (e_lfanew dosHeader) in
    let rva := (VirtualAddress_IDD (nth 0 (vtolist (DataDirectory (OptionalHeader ntHeader)))
                                           {| VirtualAddress_IDD := Word.repr 0; Size := Word.repr 0 |})) in
    match Word.unsigned rva with
    | 0%Z => nil
    | _ =>
           let sectionHeader := findSection data rva
                               ((ptr_to_nat (e_lfanew dosHeader)) + 248)
                               (word_to_nat (NumberOfSections (FileHeader ntHeader))) in
           let exportDir := parseImageExportDirectory data (dword_to_nat (vAddr_to_offset rva sectionHeader)) in
               vtolist (parseVector (parseDoubleWord) data 4
                           (dword_to_nat (vAddr_to_offset (AddressOfFunctions exportDir) sectionHeader))
                           (dword_to_nat (NumberOfFunctions exportDir)))
    end.

(* given a file, check that all exported symbols target
*  low memory chunk boundaries *)
Definition checkExports (data : list BYTE) (mask : DWORD) : bool :=
    let exports := getExports data in
    let check (addr : DWORD) : bool :=
        Word.eq addr (Word.and addr mask)
    in
    List.fold_left (andb) (List.map check exports) true
.

(*----------------------------------------------------------- *)

Definition derefDataDirectoryIAT optionalHeader : _IMAGE_DATA_DIRECTORY :=
	(nth IMAGE_DIRECTORY_ENTRY_IAT (vtolist (DataDirectory optionalHeader))
		{| VirtualAddress_IDD := Word.repr 0; Size := Word.repr 0 |})
.

Definition derefImageOptionalHeader data : _IMAGE_OPTIONAL_HEADER :=
	let dosHeader := parseImageDosHeader data in
	let ntHeader := derefImageNtHeader data (e_lfanew dosHeader) in
	OptionalHeader ntHeader
.

(* Unused, has a bug
Definition parseImageImportDescriptor (data : list BYTE) (n : nat) : _IMAGE_IMPORT_DESCRIPTOR:=
    mkImageImportDescriptor
    	(parseDoubleWord data n) 	(* OriginalFirstThunk *)
	(parseDoubleWord data (n+4))	(* TimeDataStamp_IDD *)
	(parseDoubleWord data (n+8))	(* Ordinal *)
	(parseDoubleWord data (n+12))	(* AddressOfData *)
.

unused, has a bug
Definition derefImageImportDescriptor (data : list DWORD) 
  (dataDirectory : _IMAGE_DATA_DIRECTORY) : _IMAGE_IMPORT_DESCRIPTOR :=
	(parseImageImportDescriptor data 
		(dword_to_nat dataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].VirtualAddress_IDD))
.
*)

(* this returns the RVA start address and the size as two consecutive elements in a list *)
Definition getIATBounds (data : list BYTE) : DWORD [2] :=
	let optionalHeader := derefImageOptionalHeader data in
	let IAT := derefDataDirectoryIAT optionalHeader in
	(VirtualAddress_IDD IAT) :: (Size IAT) :: [] 
.
(*
Fixpoint validateImports :=
.

Fixpoint validateExports :=
.

Definition parseSectionCharacteristics :=
.

Definition validateSection :=*)

Close Scope vector_scope.
