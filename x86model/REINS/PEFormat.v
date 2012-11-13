(* TODO:
 * 1) How to model a C union in Coq equivalently?
 * - IDEA: an inductive type
 * e.g.,
 *   union _x {
 *     WORD field_one;
 *     WORD field_two;
 *   };
 * becomes
 *   Inductive _x : Type :=
 *   | field_one : WORD -> _x
 *   | field_two : WORD -> _x.
 *
 * 2) name conflicts: some field names are repeated, but they are global names in
 *    Coq, e.g. _IMAGE_FILE_HEADER and _IMAGE_IMPORT_DESCRIPTOR both have a member
 *    named TimeDateStamp, but there can be only one TimeDateStamp (this is because
 *    Coq creates a function TimeDateStamp : _IMAGE_DOS_HEADER -> DWORD). We need
 *    to come up with a naming convention, or to use some kind of namespace stuff.
 *    This is the only thing currently keeping this file from compiling.
 *)
 

Require Import Bits.

Inductive vector : nat -> Set -> Type :=
| vnil : forall (A : Set), vector 0 A
| vcons : forall (A : Set) (n : nat), A -> vector n A -> vector (S n) A.

Notation "[]" := (vnil _).
Notation "h :: t" := (vcons _ _ h t) (at level 60, right associativity).
Notation "t [ n ]" := (vector n t) (at level 90, no associativity).


Definition BYTE := int8.
Definition WORD := int16.
Definition DWORD := int32.

Record _IMAGE_DOS_HEADER : Type  := mkImageDosHeader {
	e_magic: WORD;
	e_cblp : WORD;
	e_cp : WORD;
	e_crlc : WORD;
	e_cparhdr : WORD;
	e_minalloc : WORD;
	e_maxalloc : WORD;
	e_ss : WORD;
	e_sp : WORD;
	e_csum : WORD;
	e_ip : WORD;
	e_cs : WORD;
	e_lfarlc : WORD;
	e_ovno : WORD;
	e_res : WORD[4];
	e_oemid : WORD;
	e_oeminfo : WORD;
	e_res2 : WORD[10];
	e_lfanew : DWORD
}.

Record _IMAGE_FILE_HEADER : Type := mkImageFileHeader {
	Machine : WORD;
	NumberOfSections : WORD;
	TimeDateStamp : DWORD;
	PointerToSymbolTable : DWORD;
	NumberOfSymbols : DWORD;
	SizeOfOptionalHeader : WORD;
	Characteristics : WORD
}.

Definition IMAGE_DIRECTORY_ENTRY_EXPORT := 0.
Definition IMAGE_DIRECTORY_ENTRY_IMPORT := 1.
Definition IMAGE_DIRECTORY_ENTRY_RESOURCE := 2.
Definition IMAGE_DIRECTORY_ENTRY_EXCEPTION :=3.
Definition IMAGE_DIRECTORY_ENTRY_SECURITY :=4.
Definition IMAGE_DIRECTORY_ENTRY_BASERELOC :=5.
Definition IMAGE_DIRECTORY_ENTRY_DEBUG :=6.
Definition IMAGE_DIRECTORY_ENTRY_COPYRIGHT :=7.
Definition IMAGE_DIRECTORY_ENTRY_GLOBALPTR :=8.
Definition IMAGE_DIRECTORY_ENTRY_TLS :=9.
Definition IMAGE_DIRECTORY_ENTRY_LOAD_CONFIG :=10.
Definition IMAGE_DIRECTORY_ENTRY_BOUND_IMPORT :=11.
Definition IMAGE_DIRECTORY_ENTRY_IAT :=12.
Definition IMAGE_DIRECTORY_ENTRY_DELAY_IMPORT :=13.
Definition IMAGE_DIRECTORY_ENTRY_COM_DESCRIPTOR :=14.
Definition IMAGE_DIRECTORY_ENTRY_END :=15.

Record _IMAGE_DATA_DIRECTORY : Type := mkImageDataDirectory {
 VirtualAddress : DWORD;
 Size : DWORD
}.

Record _IMAGE_OPTIONAL_HEADER : Type := mkImageOptionalHeader {
	Magic : WORD;
	MajorLinkerVersion : BYTE;
	MinorLinkerVersion : BYTE;
	SizeOfCode : DWORD;
	SizeOfInitializedData : DWORD;
	SizeOfUninitializedData : DWORD;
	AddressOfEntryPoint : DWORD;
	BaseOfCode : DWORD;
	BaseOfData : DWORD;
	ImageBase : DWORD;
	SectionAlignment : DWORD;
	FileAlignment : DWORD;
	MajorOperatingSystemVersion : WORD;
	MinorOperatingSystemVersion : WORD;
	MajorImageVersion : WORD;
	MinorImageVersion : WORD;
	MajorSubsystemVersion : WORD;
	MinorSubsystemVersion : WORD;
	Win32VersionValue : DWORD;
	SizeOfImage : DWORD;
	SizeOfHeaders : DWORD;
	CheckSum : DWORD;
	Subsystem : WORD;
	DllCharacteristics : WORD;
	SizeOfStackReserve : DWORD;
	SizeOfStackCommit : DWORD;
	SizeOfHeapReserve : DWORD;
	SizeOfHeapCommit : DWORD;
	LoaderFlags : DWORD;
	NumberOfRvaAndSizes : DWORD;
	DataDirectory : _IMAGE_DATA_DIRECTORY[16] (* still need to make this 16 long; 
	represents an array of 16 _IMAGE_DATA_DIRECTORY types. Each one of these describes a particular thing per the Definitions above *)
}.

(*TODO: real definition *)
Definition PIMAGE_THUNK_DATA := WORD.

Record _IMAGE_IMPORT_DESCRIPTOR : Type := mkImageImportDescriptor {
	OriginalFirstThunk : PIMAGE_THUNK_DATA; (* this was unioned with a characteristics field *)
	TimeDateStamp : DWORD; 
	ForwarderChain : DWORD; 
	Name : DWORD;
	FirstThunk : PIMAGE_THUNK_DATA
}.

(*TODO: real definitions *)
Definition LPBYTE := BYTE.
Definition PDWORD := DWORD.
Definition PIMAGE_IMPORT_BY_NAME := WORD.

(* this needs to be modeled as a union *)
Record _IMAGE_THUNK_DATA : Type := mkImageThunkData{
	ForwarderString : LPBYTE;
	Function : PDWORD;
	Ordinal : DWORD;
	AddressOfData : PIMAGE_IMPORT_BY_NAME
}.

Record _IMAGE_IMPORT_BY_NAME : Type := mkImageImportByName {
 Hint : WORD;
 Name : BYTE[16]
}.

Record _IMAGE_NT_HEADERS : Type := mkImageNtHeaders {
	Signature : DWORD;
	FileHeader : _IMAGE_FILE_HEADER;
	OptionalHeader : _IMAGE_OPTIONAL_HEADER
}.
(* TODO: what is IMAGE_SIZEOF_SHORT_NAME? *)
Definition IMAGE_SIZEOF_SHORT_NAME := 1.

Record _IMAGE_SECTION_HEADER : Type := mkImageSectionHeader {
	Name : BYTE[IMAGE_SIZEOF_SHORT_NAME];
	PhysicalAddressORVirtualSize : DWORD;
	VirtualAddress : DWORD;
	SizeOfRawData : DWORD;
	PointerToRawData : DWORD;
	PointerToRelocations : DWORD;
	PointerToLinenumbers : DWORD;
	NumberOfRelocations : WORD;
	NumberOfLinenumbers : WORD;
	Characteristics : DWORD
}.

(* The following list of Definitions are used for the characteristics field, 
in order to discern the purpose and capabilities of a section of a PE file
Note: Coq doesn't support hex literals, so they are given in decimal *)
Open Scope Z_scope.
Definition IMAGE_SCN_TYPE_NO_PAD            : int32 := Word.repr 8.          (* 0x00000008 obsolete *)
Definition IMAGE_SCN_CNT_CODE               : int32 := Word.repr 32.         (* 0x00000020 The section contains executable code. *)
Definition IMAGE_SCN_CNT_INITIALIZED_DATA   : int32 := Word.repr 64.         (* 0x00000040 section contains initialized data *)
Definition IMAGE_SCN_CNT_UNINITIALIZED_DATA : int32 := Word.repr 128.        (* 0x00000080 section contains uninitialized data *)
Definition IMAGE_SCN_LNK_OTHER              : int32 := Word.repr 256.        (* 0x00000100 reserved *)
Definition IMAGE_SCN_LNK_INFO               : int32 := Word.repr 512.        (* 0x00000200 valid only for object files *)
Definition IMAGE_SCN_LNK_REMOVE             : int32 := Word.repr 2048.       (* 0x00000800 reserved *)
Definition IMAGE_SCN_LNK_COMDAT             : int32 := Word.repr 4096.       (* 0x00001000 contains COMDAT data; valid for object files *)
Definition IMAGE_SCN_NO_DEFER_SPEC_EXC      : int32 := Word.repr 16384.      (* 0x00004000 reset speculative exceptions handling bits in the TLB entries for this section *)
Definition IMAGE_SCN_GPREL                  : int32 := Word.repr 32768.      (* 0x00008000 section contains data referenced through the global pointer *)
Definition IMAGE_SCN_MEM_PURGEABLE          : int32 := Word.repr 131072.     (* 0x00020000 reserved *)
Definition IMAGE_SCN_MEM_LOCKED             : int32 := Word.repr 262144.     (* 0x00040000 reserved *)
Definition IMAGE_SCN_MEM_PRELOAD            : int32 := Word.repr 524288.     (* 0x00080000 reserved *)
Definition IMAGE_SCN_ALIGN_1BYTES           : int32 := Word.repr 1048576.    (* 0x00100000 align data on 1-byte boundary; for obj files *)
Definition IMAGE_SCN_ALIGN_2BYTES           : int32 := Word.repr 2097152.    (* 0x00200000 align data on 2-byte boundary; for obj files *)
Definition IMAGE_SCN_ALIGN_4BYTES           : int32 := Word.repr 3145728.    (* 0x00300000 align data on 4-byte boundary; for obj files *)
Definition IMAGE_SCN_ALIGN_8BYTES           : int32 := Word.repr 4194304.    (* 0x00400000 align data on 8-byte boundary; for obj files *)
Definition IMAGE_SCN_ALIGN_16BYTES          : int32 := Word.repr 5242880.    (* 0x00500000 align data on 16-byte boundary; for obj files *)
Definition IMAGE_SCN_ALIGN_32BYTES          : int32 := Word.repr 6291456.    (* 0x00600000 align data on 32-byte boundary; for obj files *)
Definition IMAGE_SCN_ALIGN_64BYTES          : int32 := Word.repr 7340032.    (* 0x00700000 align data on 64-byte boundary; for obj files *)
Definition IMAGE_SCN_ALIGN_128BYTES         : int32 := Word.repr 8388608.    (* 0x00800000 align data on 128-byte boundary; for obj files *)
Definition IMAGE_SCN_ALIGN_256BYTES         : int32 := Word.repr 9437184.    (* 0x00900000 align data on 256-byte boundary; for obj files *)
Definition IMAGE_SCN_ALIGN_512BYTES         : int32 := Word.repr 10485760.   (* 0x00A00000 align data on 512-byte boundary; for obj files *)
Definition IMAGE_SCN_ALIGN_1024BYTES        : int32 := Word.repr 11534336.   (* 0x00B00000 align data on 1024-byte boundary; for obj files *)
Definition IMAGE_SCN_ALIGN_2048BYTES        : int32 := Word.repr 12582912.   (* 0x00C00000 align data on 2048-byte boundary; for obj files *)
Definition IMAGE_SCN_ALIGN_4096BYTES        : int32 := Word.repr 13631488.   (* 0x00D00000 align data on 4096-byte boundary; for obj files *)
Definition IMAGE_SCN_ALIGN_8192BYTES        : int32 := Word.repr 14680064.   (* 0x00E00000 align data on 8196-byte boundary; for obj files *)
Definition IMAGE_SCN_LNK_NRELOC_OVFL        : int32 := Word.repr 16777216.   (* 0x01000000 section contains extended relocations *)
Definition IMAGE_SCN_MEM_DISCARDABLE        : int32 := Word.repr 33554432.   (* 0x02000000 section can be discarded *)
Definition IMAGE_SCN_MEM_NOT_CACHED         : int32 := Word.repr 67108864.   (* 0x04000000 section cannot be cached *)
Definition IMAGE_SCN_MEM_NOT_PAGED          : int32 := Word.repr 134217728.  (* 0x08000000 section cannot be paged *)
Definition IMAGE_SCN_MEM_SHARED             : int32 := Word.repr 268435456.  (* 0x10000000 section can be shared in memory *)
Definition IMAGE_SCN_MEM_EXECUTE            : int32 := Word.repr 536870912.  (* 0x20000000 section can be executed *)
Definition IMAGE_SCN_MEM_READ               : int32 := Word.repr 1073741824. (* 0x40000000 section can be read *)
Definition IMAGE_SCN_MEM_WRITE              : int32 := Word.repr 4294967295. (* 0x80000000 section can be written to *)
