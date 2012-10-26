(* If the following hold,
	All executable code resides in low memory
	All exported symbols target low memory areas
	No disassembled instructions spans a chunk boundary
	static branches target low memory chunk boundaries
	all computed jumps that do not reference the IAT are 
		immediately preceded by and-masking 
		instruction from Table 1 in the same chunk 
	Computed jumps that read the IAT access a properly 
		aligned IAT entry, and are preceded by an 
		and-mask of the return address (call 
		instructions must end on a chunk boundary 
		rather than requiring a mask, since they push
		their own return address 
	There are no trap instructions; int or syscall 
then:
	These properties ensure that any unaligned instruction sequences
concealed within untrusted, executable sections are not reachable
at runtime.
*)


