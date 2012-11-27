MODULES := Int32 PEFormat PETraversal ReinsVerifier ReinsVerifierDFA CompiledDFAs
# REINSjmp ReinsDFACorrectness X86Lemmas ReinsVerifierCorrectness
VS 	:= $(MODULES:%=%.v)

.PHONY: coq clean

coq: Makefile.coq
	$(MAKE) -f Makefile.coq

Makefile.coq: Makefile $(VS)
	echo $(VS)
	coq_makefile -I "../Model" $(VS) -o Makefile.coq

clean:: Makefile.coq
	$(MAKE) -f Makefile.coq clean
	rm -f Makefile.coq .depend
