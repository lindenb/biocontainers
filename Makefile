SHELL=/bin/bash
.PHONY=all clean docker_images bioinfo1 images
TMPDIR=tmp
	
all: docker_images

docker_images: bioinfo1

bioinfo1: dockerfiles/bioinfo1.dockerfile
	cat $< | docker build --no-cache -t $@ -

dockerfiles/bioinfo1.dockerfile : make/recipes.mk
	mkdir -p $(dir $@)
	$(MAKE) --silent -f make/recipes.mk bedtools.src htslib.src > $(addsuffix .tmp,$@)
	mv -v $(addsuffix .tmp,$@) $@
	cat $@

images:
	docker images

clean:
	docker image prune --all --force
	docker volume prune --all --force
