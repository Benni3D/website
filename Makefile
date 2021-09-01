templatesdir = content/templates

ifeq ($(no_upload),)
UPLOAD=sh scripts/upload.sh
else
UPLOAD=\#
endif

all: all-templates all-dirs all-static all-docs all-cats

reupload:
	sh scripts/upload.sh sites

full-clean: clean
	rm -rf .cache

clean:
	rm -rf sites
	rm -f $(templatesdir)/top.html

###############################################################################
#										Templates													#
###############################################################################

all-templates: $(templatesdir)/top.html

# Generate top.html from top.html.in & links.lst
$(templatesdir)/top.html: $(templatesdir)/top.html.in $(templatesdir)/links.lst scripts/gen_top.sh
	@echo Generating \'$@\'
	@sh scripts/gen_top.sh >$(templatesdir)/top.html

###############################################################################
#										Directories													#
###############################################################################

content-dirs	= img styles vids
sites-dirs		= $(patsubst %,sites/%,$(content-dirs))
images			= $(wildcard content/img.d/*)

all-dirs: $(sites-dirs)

# Copy the img directory
#sites/img: content/img.d $(images)
#	@echo Copying '$<' -> '$@'
#	@mkdir -p sites
#	@rm -rf $@
#	@cp -r $< $@
#	@$(UPLOAD) $@

# Copy all other directories
sites/%: content/%.d
	@echo Copying \'$<\' '->' \'$@\'
	@mkdir -p sites
	@rm -rf $@
	@cp -r $< $@
	@$(UPLOAD) $@

###############################################################################
#										Static webpages											#
###############################################################################

content-static	= EG1.html			\
					  EG2.html			\
					  impressum.html	\
					  index.html		\
					  memes.html
sites-static	= $(patsubst %.html,sites/%.html,$(content-static))

all-static: $(sites-static)

# Generate a static website from the top.html template
sites/%.html: content/%.html $(templatesdir)/top.html
	@echo Generating \'$@\'
	@mkdir -p sites
	@sed -e '/__REPLACE__/r$<' -e '/__REPLACE__/d' $(templatesdir)/top.html >$@
	@$(UPLOAD) $@

###############################################################################
#										Cat images													#
###############################################################################

cats			= $(shell sed 's/^\([^|]*\)|.*$$/\1/' content/templates/cats.lst)
cat-images	= $(patsubst %,content/img.d/%,$(cats))
cat-htmls 	= $(patsubst content/img.d/%.jpg,sites/%.html,$(cat-images))

all-cats: $(cat-htmls) sites/cat.html
#sites/Cat_%.html: content/img.d/Cat_%.jpg sites/img $(templatesdir)/single-cat.html $(templatesdir)/top.html
#	@echo Generating \'$@\'
#	@mkdir -p sites
#	@sed -e 's,__CAT__,$(patsubst content/img.d/%,img/%,$<),'	\
#		 -e "s,__STYLE__,cat,"		\
#		 $(templatesdir)/single-cat.html >			\
#		 $@.in
#	@sed -e '/__REPLACE__/r$@.in' \
#		 -e '/__REPLACE__/d'			\
#		 $(templatesdir)/top.html	> $@
#	@rm $@.in
#	@$(UPLOAD) $@


## Single Cats

.PRECIOUS: $(patsubst sits/%.html,.cache/%.html.in,$(cat-htmls))

# Generate Cat_N.html from Cat_N.html.in
sites/Cat_%.html: .cache/Cat_%.html.in $(templatesdir)/top.html
	@mkdir -p sites
	@sed 	-e '/__REPLACE__/r$<'	\
			-e '/__REPLACE__/d'		\
			$(templatesdir)/top.html >$@

# Generate Cat_N.html.in
.cache/Cat_%.html.in: content/img.d/Cat_%.jpg $(templatesdir)/single-cat.html
	@echo Generating '$(patsubst .cache/%.in,%,$@)'
	@mkdir -p .cache
	@sed	-e 's,__CAT__,$(patsubst content/img.d/%,img/%,$<),'	\
			-e 's,__STYLE__,cat,'											\
			$(templatesdir)/single-cat.html >$@

## Full Cat View

# Generate cat.html from cat.html.in
sites/cat.html: .cache/cat.html.in $(templatesdir)/top.html
	@mkdir -p sites
	@sed -e '/__REPLACE__/r$<' -e '/__REPLACE__/d' $(templatesdir)/top.html >$@
	@$(UPLOAD) $@

# Generate cat.html.in from cat.html.lst
.cache/cat.html.in: .cache/cat.html.lst $(templatesdir)/cat.html
	@sed -e '/__CATS__/r$<' -e '/__CATS__/d' $(templatesdir)/cat.html >$@

# Generate cat.html.lst from cats.lst
.cache/cat.html.lst: $(templatesdir)/cats.lst $(cat-images) scripts/gen_cat.sh
	@echo Generating 'sites/cat.html'
	@mkdir -p .cache
	@sh scripts/gen_cat.sh $(cat-images) >$@

###############################################################################
#								Documentation and Man pages									#
###############################################################################

all-docs: sites/bcc.1.html all-microcoreutils

### Brainlet C Compiler
bcc-man-pages=https://raw.githubusercontent.com/Benni3D/bcc/master/src

# Generate bcc.1.html from bcc.1.html.in
sites/bcc.1.html: .cache/bcc.1.html.in $(templatesdir)/top.html
	@echo Generating \'$@\'
	@mkdir -p sites
	@sed -e '/__REPLACE__/r$<' -e '/__REPLACE__/d' $(templatesdir)/top.html >$@
	@$(UPLOAD) $@

# Generate bcc.1.html.in from bcc.1
.cache/bcc.1.html.in: .cache/bcc.1
	@sh scripts/gen_bcc.sh >$@

# Download bcc.1
.cache/bcc.1:
	@echo Downloading \'$@\'
	@mkdir -p .cache
	@curl $(bcc-man-pages)/bcc.1 >$@ 2>/dev/null

### Microcoreutils
mc-man-pageurl=https://raw.githubusercontent.com/Benni3D/microcoreutils/master/doc
mc-man-pages=$(shell grep -v '^\s*#' $(templatesdir)/microcoreutils.lst)
mc-gen-pages=$(patsubst %,sites/mc-%.html,$(mc-man-pages))

all-microcoreutils: sites/mc-summary.html $(mc-gen-pages) $(templatesdir)/microcoreutils.lst

## Summary page

# Generate mc-summary.html from mc-summary.html.in
sites/mc-summary.html: .cache/mc-summary.html.in
	@echo Generating \'$@\'
	@mkdir -p sites
	@sed -e '/__REPLACE__/r$<' -e '/__REPLACE__/d' $(templatesdir)/top.html >$@
	@$(UPLOAD) $@

# Generate mc-summary.html.in from microcoreutils.lst
.cache/mc-summary.html.in: $(templatesdir)/microcoreutils.lst scripts/gen_mclist.sh
	@mkdir -p .cache
	@sh scripts/gen_mclist.sh $< >$@
	
## Individual pages

# Generate %.html from %.html.in
sites/mc-%.html: .cache/mc-%.html.in $(templatesdir)/top.html
	@echo Generating \'$@\'
	@mkdir -p sites
	@sed -e '/__REPLACE__/r$<' -e '/__REPLACE__/d' $(templatesdir)/top.html >$@
	@$(UPLOAD) $@

# Generate mc-%.html.in from mc-%
.cache/mc-%.html.in: .cache/mc-man-% scripts/gen_mc.sh
	@mkdir -p .cache
	@sh scripts/gen_mc.sh $< >$@

# Download man page
.cache/mc-man-%:
	@echo Downloading \'$@\'
	@mkdir -p .cache
	@curl $(mc-man-pageurl)/$(patsubst .cache/mc-man-%,%,$@) \
		>$@ 2>/dev/null


.PHONY:	all reupload full-clean clean			\
			all-templates all-dirs all-static	\
			all-cats all-docs
