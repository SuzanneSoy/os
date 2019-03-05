all: deps.svg deps.png deps.pdf

deps.dot: deps.sh
  sh $< > $@

deps.svg: deps.dot Makefile
  dot -Tsvg $< > $@

deps.png: deps.dot Makefile
  dot -Tpng $< > $@

deps.ps: deps.dot Makefile
  dot -Tpng $< > $@

deps.pdf: deps.ps Makefile
  ps2pdf $< $@

