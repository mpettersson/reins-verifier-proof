(* How do I model a C union in Coq equivalently? *)
(* How should I define DWORD? *)
(* How do I define a vector as t? *)


Record _IMAGE_DOS_HEADER : Set  := mkImageDosHeader {
	e_magic : WORD;
	e_cblp : WORD;
	e_cp : WORD;
	e_crlc : WORD;
	e_cparhdr : WORD;
	e_minalloc : WORD;
	e_maxalloc : WORD;
	e_ss
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
	e_res[4] : WORD;
	e_oemid : WORD;
	e_oeminfo : WORD;
	e_res2[10] : WORD;
	e_lfanew : DWORD;
}

Record _IMAGE_FILE_HEADER {
	Machine : WORD;
	NumberOfSections : WORD;
	TimeDateStamp : DWORD;
	PointerToSymbolTable : DWORD;
	NumberOfSymbols : DWORD;
	SizeOfOptionalHeader : WORD;
	Characteristics : WORD;
};

Definition IMAGE_DIRECTORY_ENTRY_EXPORT := 0;
Definition IMAGE_DIRECTORY_ENTRY_IMPORT := 1;
Definition IMAGE_DIRECTORY_ENTRY_RESOURCE := 2;
Definition IMAGE_DIRECTORY_ENTRY_EXCEPTION :=3;
Definition IMAGE_DIRECTORY_ENTRY_SECURITY :=4;
Definition IMAGE_DIRECTORY_ENTRY_BASERELOC :=5;
Definition IMAGE_DIRECTORY_ENTRY_DEBUG :=6;
Definition IMAGE_DIRECTORY_ENTRY_COPYRIGHT :=7;
Definition IMAGE_DIRECTORY_ENTRY_GLOBALPTR :=8;
Definition IMAGE_DIRECTORY_ENTRY_TLS :=9;
Definition IMAGE_DIRECTORY_ENTRY_LOAD_CONFIG :=10;
Definition IMAGE_DIRECTORY_ENTRY_BOUND_IMPORT :=11;
Definition IMAGE_DIRECTORY_ENTRY_IAT :=12;
Definition IMAGE_DIRECTORY_ENTRY_DELAY_IMPORT :=13;
Definition IMAGE_DIRECTORY_ENTRY_COM_DESCRIPTOR :=14;
Definition IMAGE_DIRECTORY_ENTRY_END :=15

Record _IMAGE_DATA_DIRECTORY {
 VirtualAddress : DWORD;
 Size : DWORD;
};

Record _IMAGE_OPTIONAL_HEADER {
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
	DataDirectory : vector _IMAGE_DATA_DIRECTORY 16; (* still need to make this 16 long; 
	represents an array of 16 _IMAGE_DATA_DIRECTORY types. Each one of these describes a particular thing per the Definitions above *)
};

Record _IMAGE_IMPORT_DESCRIPTOR {
	OriginalFirstThunk : PIMAGE_THUNK_DATA; (* this was unioned with a characteristics field *)
	TimeDateStamp : DWORD; 
	ForwarderChain : DWORD; 
	Name : DWORD;
	FirstThunk : PIMAGE_THUNK_DATA;
};

(* this needs to be modeled as a union *)
typedef struct _IMAGE_THUNK_DATA {
	ForwarderString : LPBYTE;
	Function : PDWORD;
	Ordinal : DWORD;
	AddressOfData : PIMAGE_IMPORT_BY_NAME;
}

typedef struct _IMAGE_IMPORT_BY_NAME {
 Hint : WORD;
 Name : vector 16 BYTE;
}

Record _IMAGE_NT_HEADERS {
	Signature : DWORD;
	FileHeader : _IMAGE_FILE_HEADER;
	OptionalHeader : _IMAGE_OPTIONAL_HEADER;
};

Record _IMAGE_SECTION_HEADER {
	Name[IMAGE_SIZEOF_SHORT_NAME] : BYTE;
	PhysicalAddressORVirtualSize : DWORD;
	VirtualAddress : DWORD;
	SizeOfRawData : DWORD;
	PointerToRawData : DWORD;
	PointerToRelocations : DWORD;
	PointerToLinenumbers : DWORD;
	NumberOfRelocations : WORD;
	NumberOfLinenumbers : WORD;
	Characteristics : DWORD;
};

 (*
Flag	Meaning
0x00000000
Reserved.
0x00000001
Reserved.
0x00000002
Reserved.
0x00000004
Reserved.
IMAGE_SCN_TYPE_NO_PAD
0x00000008
The section should not be padded to the next boundary. This flag is obsolete and is replaced by IMAGE_SCN_ALIGN_1BYTES.
0x00000010
Reserved.
IMAGE_SCN_CNT_CODE
0x00000020
The section contains executable code.
IMAGE_SCN_CNT_INITIALIZED_DATA
0x00000040
The section contains initialized data.
IMAGE_SCN_CNT_UNINITIALIZED_DATA
0x00000080
The section contains uninitialized data.
IMAGE_SCN_LNK_OTHER
0x00000100
Reserved.
IMAGE_SCN_LNK_INFO
0x00000200
The section contains comments or other information. This is valid only for object files.
0x00000400
Reserved.
IMAGE_SCN_LNK_REMOVE
0x00000800
The section will not become part of the image. This is valid only for object files.
IMAGE_SCN_LNK_COMDAT
0x00001000
The section contains COMDAT data. This is valid only for object files.
0x00002000
Reserved.
IMAGE_SCN_NO_DEFER_SPEC_EXC
0x00004000
Reset speculative exceptions handling bits in the TLB entries for this section.
IMAGE_SCN_GPREL
0x00008000
The section contains data referenced through the global pointer.
0x00010000
Reserved.
IMAGE_SCN_MEM_PURGEABLE
0x00020000
Reserved.
IMAGE_SCN_MEM_LOCKED
0x00040000
Reserved.
IMAGE_SCN_MEM_PRELOAD
0x00080000
Reserved.
IMAGE_SCN_ALIGN_1BYTES
0x00100000
Align data on a 1-byte boundary. This is valid only for object files.
IMAGE_SCN_ALIGN_2BYTES
0x00200000
Align data on a 2-byte boundary. This is valid only for object files.
IMAGE_SCN_ALIGN_4BYTES
0x00300000
Align data on a 4-byte boundary. This is valid only for object files.
IMAGE_SCN_ALIGN_8BYTES
0x00400000
Align data on a 8-byte boundary. This is valid only for object files.
IMAGE_SCN_ALIGN_16BYTES
0x00500000
Align data on a 16-byte boundary. This is valid only for object files.
IMAGE_SCN_ALIGN_32BYTES
0x00600000
Align data on a 32-byte boundary. This is valid only for object files.
IMAGE_SCN_ALIGN_64BYTES
0x00700000
Align data on a 64-byte boundary. This is valid only for object files.
IMAGE_SCN_ALIGN_128BYTES
0x00800000
Align data on a 128-byte boundary. This is valid only for object files.
IMAGE_SCN_ALIGN_256BYTES
0x00900000
Align data on a 256-byte boundary. This is valid only for object files.
IMAGE_SCN_ALIGN_512BYTES
0x00A00000
Align data on a 512-byte boundary. This is valid only for object files.
IMAGE_SCN_ALIGN_1024BYTES
0x00B00000
Align data on a 1024-byte boundary. This is valid only for object files.
IMAGE_SCN_ALIGN_2048BYTES
0x00C00000
Align data on a 2048-byte boundary. This is valid only for object files.
IMAGE_SCN_ALIGN_4096BYTES
0x00D00000
Align data on a 4096-byte boundary. This is valid only for object files.
IMAGE_SCN_ALIGN_8192BYTES
0x00E00000
Align data on a 8192-byte boundary. This is valid only for object files.
IMAGE_SCN_LNK_NRELOC_OVFL
0x01000000
The section contains extended relocations. The count of relocations for the section exceeds the 16 bits that is reserved for it in the section header. If the NumberOfRelocations field in the section header is 0xffff, the actual relocation count is stored in the VirtualAddress field of the first relocation. It is an error if IMAGE_SCN_LNK_NRELOC_OVFL is set and there are fewer than 0xffff relocations in the section.
IMAGE_SCN_MEM_DISCARDABLE
0x02000000
The section can be discarded as needed.
IMAGE_SCN_MEM_NOT_CACHED
0x04000000
The section cannot be cached.
IMAGE_SCN_MEM_NOT_PAGED
0x08000000
The section cannot be paged.
IMAGE_SCN_MEM_SHARED
0x10000000
The section can be shared in memory.
IMAGE_SCN_MEM_EXECUTE
0x20000000
The section can be executed as code.
IMAGE_SCN_MEM_READ
0x40000000
The section can be read.
IMAGE_SCN_MEM_WRITE
0x80000000
The section can be written to.


*)
