SHELL=/bin/bash
.PHONY=all clean clean.image clean.volume docker_images bioinfo1 images
TMPDIR=tmp
	
all: docker_images

docker_images: bioinfo1

bioinfo1: dockerfiles/bioinfo1.dockerfile
	cat $< | BUILDKIT_PROGRESS=plain docker build -t $@ -

dockerfiles/bioinfo1.dockerfile : make/recipes.mk
	mkdir -p $(dir $@)
	$(MAKE) --silent -f make/recipes.mk  jvarkit.github > $(addsuffix .tmp,$@)
	mv -v $(addsuffix .tmp,$@) $@
	cat $@


example01.png: make/recipes.mk
	$(MAKE) -nBd -f $< r.ggplot2  bwa.src gatk4.github  jvarkit.github samtools.src bcftools.src jvarkit.github |\
	../makefile2graph/make2graph |\
	dot -Tpng -o $@
	

images:
	docker images

clean.image: images
	docker image prune --all --force

clean.volume: images
	docker volume prune --all --force

clean.system: images
	docker system prune --all --force

clean: clean.image clean.volume clean.system


