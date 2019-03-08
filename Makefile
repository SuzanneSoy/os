all: artifacts/deps.svg artifacts/deps.png artifacts/deps.pdf artifacts/index.html artifacts/references/index.html

deps.dot: deps.sh
	mkdir -p $$(dirname $@)
	sh $< > $@

artifacts/deps.svg: deps.dot Makefile
	mkdir -p $$(dirname $@)
	dot -Tsvg $< > $@

artifacts/deps.png: deps.dot Makefile
	mkdir -p $$(dirname $@)
	dot -Tpng $< > $@

deps.ps: deps.dot Makefile
	mkdir -p $$(dirname $@)
	dot -Tps  $< > $@

artifacts/deps.pdf: deps.ps Makefile
	mkdir -p $$(dirname $@)
	ps2pdf $< $@

artifacts/index.html: Makefile
	cp doc-src/index.html $@

artifacts/references/index.html:
	markdown -o $@ references.md
