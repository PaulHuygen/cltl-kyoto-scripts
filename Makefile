
.SUFFIXES: .pdf .w .tex .html .aux .log .php
.PHONY : html

DIRS = bin

$(DIRS) :
	mkdir -p $@

htmldir :
	mkdir -p html

#
# Figures
#

figfiles=$(shell ls *.fig)
figbases=$(basename $(figfiles))

#
# PDF figures
#

pdft_names=$(foreach fil,$(figbases), $(fil).pdftex_t)
pdf_fig_names=$(foreach fil,$(figbases), $(fil).pdftex)

%.pdftex: %.fig
	fig2dev -L pdftex $< > $@

.PRECIOUS : %.pdftex
%.pdftex_t: %.fig %.pdftex
	fig2dev -L pdftex_t -p $*.pdftex $< > $@

%.pdf : %.w $(W2PDF) $(pdf_fig_names) $(pdft_names)
	chmod 775 $(W2PDF)
	$(W2PDF) $*

#
# HTML figures
#
hfigfiles=$(foreach fil, $(figfiles), html/$(fil))

pst_names=$(foreach fil, $(figbases), html/$(fil).pstex_t)
psfig_names=$(foreach fil, $(figbases), html/$(fil).pstex)



html/%.pstex : %.fig htmldir
	fig2dev -L pstex $< > $@

html/%.pstex_t : %.fig html/%.pstex htmldir
	fig2dev -L pstex_t -p html/$*.pstex $*.fig > $@

html/cltl_kyoto_scripts.w : cltl_kyoto_scripts.w htmldir
	cd html && ln -fs ../cltl_kyoto_scripts.w .

#
# Nuweb
#

m4_cltl_kyoto_scripts.w : a_cltl_kyoto_scripts.w
	gawk '{if(match($$0, "@%")) {printf("%s", substr($$0,1,RSTART-1))} else print}' $< \
          | gawk '{gsub(/[\\][\$$]/, "$$");print}'  > $@

cltl_kyoto_scripts.w : m4_cltl_kyoto_scripts.w 
	m4 -P $< > $@


sources : cltl_kyoto_scripts.w $(DIRS)
	nuweb cltl_kyoto_scripts.w

pdf : cltl_kyoto_scripts.w  $(pdf_fig_names) $(pdft_names)
	./w2pdf $<

# html : $(hfigfiles)

html : $(psfig_names) $(pst_names) html/cltl_kyoto_scripts.w htmldir
	cd html && export TEXINPUTS=../: && ../w2html cltl_kyoto_scripts


