
Require Import PEFormat.

Require Import List.

Fixpoint rvaToPtr :=
.

Fixpoint ptrToRva :=
.

Definition parseWord (data : list BYTE) (n : nat) : WORD := 
	(nth (n+1) data) * 16*16 + (nth n data).
.

Definition parseDoubleWord (data : list BYTE) (n : nat) : DWORD :=
        (parseWord data n+2) * 16*16*16*16 + (parseWord data n)
.

Definition init data := 
        initImageDosHeader data
        initFileHeader data
        initOptionalHeader data
        initImageDataDirectory data
        initExports data
        initImports data
        initSectionHeader data
        
.


Definition initImageDosHeader :=
	_IMAGE_DOS_HEADER.e_magic = (parseWord data 0);
	e_cblp = (parseWord data 2);
	e_cp = (parseWord data 4);
	e_crlc = (parseWord data 6);
	e_cparhdr = (parseWord data 8);
	e_minalloc = (parseWord data 10);
	e_maxalloc = (parseWord data 12);
	e_ss = (parseWord data 14);
	e_sp = (parseWord data 16);
	e_csum = (parseWord data 18);
	e_ip = (parseWord data 20);
	e_cs = (parseWord data 22);
	e_lfarlc = (parseWord data 24);
	e_ovno : (parseWord data 26);
	e_res : (parseWord data 28);
	e_oemid : WORD;
	e_oeminfo : WORD;
	e_res2 : WORD[10];
	e_lfanew : DWORD
.

Definition initFileHeader :=
.

Definition initOptionalHeader :=
.

Definition initImageDataDirectory :=
.

Fixpoint initExports :=
.

Fixpoint initImports :=
.

Fixpoint initSectionHeader :=
.





Fixpoint validateImports :=
.

Fixpoint validateExports :=
.

Definition parseSectionCharacteristics :=
.

Definition validateSection :=
