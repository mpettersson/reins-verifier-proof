
all:
	$(MAKE) -c Model
	$(MAKE) -c REINS
	$(MAKE) -c Test

clean: 
	rm Model/*.vo
	rm Model/*.v.d
	rm Model/*.glob
	rm REINS/*.vo
	rm REINS/*.v.d
	rm REINS/*.glob
