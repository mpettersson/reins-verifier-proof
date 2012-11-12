(* How do I model a C union in Coq equivalently? *)
(* How should I define DWORD? *)

Require Import Bits.

Inductive vector A : nat -> Type :=
| vnil : vector A 0
| vcons : forall (h:A) (n:nat), vector A n -> vector A (S n).

Notation "[]" := (vnil _).
Notation "h :: t" := (vcons _ h _ t) (at level 60, right associativity).


Record _IMAGE_DOS_HEADER : Set  := mkImageDosHeader {
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
	e_res : vector WORD 4;
	e_oemid : WORD;
	e_oeminfo : WORD;
	e_res2 : vector WORD 10;
	e_lfanew : DWORD
}.

Record _IMAGE_FILE_HEADER : Set := mkImageFileHeader {
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

Record _IMAGE_DATA_DIRECTORY : Set := mkImageDataDirectory {
 VirtualAddress : DWORD;
 Size : DWORD
}.

Record _IMAGE_OPTIONAL_HEADER : Set := mkImageOptionalHeader {
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
	DataDirectory : vector _IMAGE_DATA_DIRECTORY 16 (* still need to make this 16 long; 
	represents an array of 16 _IMAGE_DATA_DIRECTORY types. Each one of these describes a particular thing per the Definitions above *)
}.

Record _IMAGE_IMPORT_DESCRIPTOR : Set := mkImageImportDescriptor {
	OriginalFirstThunk : PIMAGE_THUNK_DATA; (* this was unioned with a characteristics field *)
	TimeDateStamp : DWORD; 
	ForwarderChain : DWORD; 
	Name : DWORD;
	FirstThunk : PIMAGE_THUNK_DATA
}.

(* this needs to be modeled as a union *)
Record _IMAGE_THUNK_DATA : Set := mkImageThunkData{
	ForwarderString : LPBYTE;
	Function : PDWORD;
	Ordinal : DWORD;
	AddressOfData : PIMAGE_IMPORT_BY_NAME
}.

Record _IMAGE_IMPORT_BY_NAME : Set := mkImageImportByName {
 Hint : WORD;
 Name : vector 16 BYTE
}.

Record _IMAGE_NT_HEADERS : Set := mkImageNtHeaders {
	Signature : DWORD;
	FileHeader : _IMAGE_FILE_HEADER;
	OptionalHeader : _IMAGE_OPTIONAL_HEADER
}.

Record _IMAGE_SECTION_HEADER : Set := mkImageSectionHeader {
	Name[IMAGE_SIZEOF_SHORT_NAME] : BYTE;
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
in order to discern the purpose and capabilities of a section of a PE file *)
Definition IMAGE_SCN_TYPE_NO_PAD := 0x00000008; (* obsolete *)
Definition IMAGE_SCN_CNT_CODE := 0x00000020; (* The section contains executable code. *)
Definition IMAGE_SCN_CNT_INITIALIZED_DATA := 0x00000040 (* section contains initialized data *)
Definition IMAGE_SCN_CNT_UNINITIALIZED_DATA 0x00000080 (* section contains uninitialized data *)
Definition IMAGE_SCN_LNK_OTHER 0x00000100 (* reserved *)
Definition IMAGE_SCN_LNK_INFO 0x00000200 (* valid only for object files *)
Definition IMAGE_SCN_LNK_REMOVE 0x00000800 (* reserved *)
Definition IMAGE_SCN_LNK_COMDAT 0x00001000 (* contains COMDAT data; valid for object files *)
Definition IMAGE_SCN_NO_DEFER_SPEC_EXC := 0x00004000; (* reset speculative exceptions handling bits in the TLB entries for this section *)
Definition IMAGE_SCN_GPREL := 0x00008000; (* section contains data referenced through the global pointer *)
Definition IMAGE_SCN_MEM_PURGEABLE := 0x00020000; (* reserved *)
Definition IMAGE_SCN_MEM_LOCKED := 0x00040000; (* reserved *)
Definition IMAGE_SCN_MEM_PRELOAD := 0x00080000; (* reserved *)
Definition IMAGE_SCN_ALIGN_1BYTES := 0x00100000; (* align data on 1-byte boundary; for obj files *)
Definition IMAGE_SCN_ALIGN_2BYTES := 0x00200000; (* align data on 2-byte boundary; for obj files *)
Definition IMAGE_SCN_ALIGN_4BYTES := 0x00300000; (* align data on 4-byte boundary; for obj files *)
Definition IMAGE_SCN_ALIGN_8BYTES := 0x00400000; (* align data on 8-byte boundary; for obj files *)
Definition IMAGE_SCN_ALIGN_16BYTES := 0x00500000; (* align data on 16-byte boundary; for obj files *)
Definition IMAGE_SCN_ALIGN_32BYTES := 0x00600000; (* align data on 32-byte boundary; for obj files *)
Definition IMAGE_SCN_ALIGN_64BYTES := 0x00700000; (* align data on 64-byte boundary; for obj files *)
Definition IMAGE_SCN_ALIGN_128BYTES := 0x00800000; (* align data on 128-byte boundary; for obj files *)
Definition IMAGE_SCN_ALIGN_256BYTES := 0x00900000; (* align data on 256-byte boundary; for obj files *)
Definition IMAGE_SCN_ALIGN_512BYTES := 0x00A00000; (* align data on 512-byte boundary; for obj files *)
Definition IMAGE_SCN_ALIGN_1024BYTES := 0x00B00000; (* align data on 1024-byte boundary; for obj files *)
Definition IMAGE_SCN_ALIGN_2048BYTES := 0x00C00000; (* align data on 2048-byte boundary; for obj files *)
Definition IMAGE_SCN_ALIGN_4096BYTES := 0x00D00000; (* align data on 4096-byte boundary; for obj files *)
Definition IMAGE_SCN_ALIGN_8192BYTES := 0x00E00000; (* align data on 8196-byte boundary; for obj files *)
Definition IMAGE_SCN_LNK_NRELOC_OVFL := 0x01000000; (* section contains extended relocations *)
Definition IMAGE_SCN_MEM_DISCARDABLE := 0x02000000; (* section can be discarded *)
Definition IMAGE_SCN_MEM_NOT_CACHED := 0x04000000; (* section cannot be cached *)
Definition IMAGE_SCN_MEM_NOT_PAGED := 0x08000000; (* section cannot be paged *)
Definition IMAGE_SCN_MEM_SHARED := 0x10000000; (* section can be shared in memory *) 
Definition IMAGE_SCN_MEM_EXECUTE := 0x20000000; (* section can be executed *)
Definition IMAGE_SCN_MEM_READ := 0x40000000; (* section can be read *)
Definition IMAGE_SCN_MEM_WRITE := 0x80000000; (* section can be written to *)
