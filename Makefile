templatesdir = content/templates

ifeq ($(no_upload),)
UPLOAD=sh scripts/upload.sh
else
UPLOAD=\#
endif

all: all-templates all-dirs all-static all-docs all-cats

full-clean: clean
	rm -rf .cache

clean:
	rm -rf sites
	rm -f $(templatesdir)/top.html

# Templates
all-templates: $(templatesdir)/top.html
$(templatesdir)/top.html: $(templatesdir)/top.html.in $(templatesdir)/links.lst scripts/gen_top.sh
	@echo Generating \'$@\'
	@sh scripts/gen_top.sh >$(templatesdir)/top.html

# Copy styles, img, vids
content-dirs	= styles img vids
sites-dirs		= $(patsubst %,sites/%,$(content-dirs))

all-dirs: $(sites-dirs)
sites/%: content/%.d
	@echo Copying \'$<\' '->' \'$@\'
	@mkdir -p sites
	@cp -r $< $@
	@$(UPLOAD) $@

images=$(wildcard content/img.d/*)
sites/img: content/img.d $(images)
	@echo Copying \'$<\' -> \'$@\'
	@mkdir -p sites
	@rm -rf $@
	@cp -r $< $@
	@$(UPLOAD) $@

# Generate static sites
content-static	= EG1.html			\
					  EG2.html			\
					  impressum.html	\
					  index.html		\
					  memes.html
sites-static	= $(patsubst %.html,sites/%.html,$(content-static))

all-static: $(sites-static)
sites/%.html: content/%.html $(templatesdir)/top.html
	@echo Generating \'$@\'
	@mkdir -p sites
	@sed -e '/__REPLACE__/r$<' -e '/__REPLACE__/d' $(templatesdir)/top.html >$@
	@$(UPLOAD) $@


# Generate cat images
cats			= $(shell sed 's/^\([^|]*\)|.*$$/\1/' content/templates/cats.lst)
cat-images	= $(patsubst %,content/img.d/%,$(cats))
cat-htmls 	= $(patsubst content/img.d/%.jpg,sites/%.html,$(cat-images))

all-cats: $(cat-htmls) sites/cat.html
sites/Cat_%.html: content/img.d/Cat_%.jpg sites/img $(templatesdir)/single-cat.html $(templatesdir)/top.html
	@echo Generating \'$@\'
	@mkdir -p sites
	@sed -e 's,__CAT__,$(patsubst content/img.d/%,img/%,$<),'	\
		 -e "s,__STYLE__,cat,"		\
		 $(templatesdir)/single-cat.html >			\
		 $@.in
	@sed -e '/__REPLACE__/r$@.in' \
		 -e '/__REPLACE__/d'			\
		 $(templatesdir)/top.html	> $@
	@rm $@.in
	@$(UPLOAD) $@

sites/cat.html: $(cat-images) $(templatesdir)/cat.html $(templatesdir)/top.html scripts/gen_cat.sh $(templatesdir)/cats.lst
	@echo Generating \'$@\'
	@mkdir -p sites
	@sh scripts/gen_cat.sh -v $(cat-images) >$@.pre
	@sed -e '/__CATS__/r$@.pre' -e '/__CATS__/d' $(templatesdir)/cat.html >$@.in
	@sed -e '/__REPLACE__/r$@.in' -e '/__REPLACE__/d' $(templatesdir)/top.html >$@
	@rm -f $@.pre $@.in
	@$(UPLOAD) $@


# Documentation/Man pages
all-docs: sites/bcc.1.html
sites/bcc.1.html: .cache/bcc.1 $(templatesdir)/top.html
	@echo Generating \'$@\'
	@sh scripts/gen_bcc.sh >$@.in
	@sed -e '/__REPLACE__/r$@.in' -e '/__REPLACE__/d' $(templatesdir)/top.html >$@
	@$(UPLOAD) $@
.cache/bcc.1:
	@echo Downloading \'$@\'
	@mkdir -p .cache
	@curl https://raw.githubusercontent.com/Benni3D/bcc/master/src/bcc.1 >$@ 2>/dev/null
