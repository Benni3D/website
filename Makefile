templatesdir = content/templates
TOP=.cache/top.html

ifeq ($(no_upload),)
UPLOAD=sh scripts/upload.sh
else
UPLOAD=\#
endif

all: all-templates all-dirs all-static all-docs all-cats all-stories

reupload:
	sh scripts/upload.sh sites

clean:
	rm -rf sites .cache

###############################################################################
#										Templates													#
###############################################################################

all-templates: $(TOP)

# Generate $(TOP) from top.html.in, top.html
$(TOP): .cache/top.html.in $(templatesdir)/top.html 
	@echo Generating \'$@\'
	@mkdir -p .cache
	@sed -e '/__LINKS__/r$<' -e '/__LINKS__/d' <$(templatesdir)/top.html >$@

# Generate top.html.in from links.lst
.cache/top.html.in: $(templatesdir)/links.lst scripts/gen_links.sh
	@mkdir -p .cache
	@sh scripts/gen_links.sh <$< >$@

###############################################################################
#										Directories													#
###############################################################################

content-dirs	= img styles vids files
sites-dirs		= $(patsubst %,sites/%,$(content-dirs))
images			= $(wildcard content/img.d/*)

all-dirs: $(sites-dirs)

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

content-static = $(shell grep -v '^\s*#' $(templatesdir)/static.lst)
sites-static	= $(patsubst %,sites/%.html,$(content-static))

all-static: $(sites-static) $(templatesdir)/static.lst

# Generate a static website from the top.html template
sites/%.html: content/%.html $(TOP)
	@echo Generating \'$@\'
	@mkdir -p sites
	@sed -e '/__REPLACE__/r$<' -e '/__REPLACE__/d' $(TOP) >$@
	@$(UPLOAD) $@

###############################################################################
#										Cat images													#
###############################################################################

cats			= $(shell grep -v '^\s*#' content/templates/cats.lst | sed 's/^\([^|]*\)|.*$$/\1/')
cat-images	= $(patsubst %,content/img.d/%,$(cats))
cat-htmls 	= $(patsubst content/img.d/%.jpg,sites/%.html,$(cat-images))

all-cats: $(cat-htmls) sites/cat.html

## Single Cats

.PRECIOUS: $(patsubst sits/%.html,.cache/%.html.in,$(cat-htmls))

# Generate Cat_N.html from Cat_N.html.in
sites/Cat_%.html: .cache/Cat_%.html.in $(TOP)
	@mkdir -p sites
	@sed 	-e '/__REPLACE__/r$<'	\
			-e '/__REPLACE__/d'		\
			$(TOP) >$@
	@$(UPLOAD) $@

# Generate Cat_N.html.in
.cache/Cat_%.html.in: content/img.d/Cat_%.jpg $(templatesdir)/single-cat.html
	@echo Generating '$(patsubst .cache/%.in,%,$@)'
	@mkdir -p .cache
	@sed	-e 's,__CAT__,$(patsubst content/img.d/%,img/%,$<),'	\
			-e 's,__STYLE__,cat,'											\
			$(templatesdir)/single-cat.html >$@

## Full Cat View

# Generate cat.html from cat.html.in
sites/cat.html: .cache/cat.html.in $(TOP)
	@mkdir -p sites
	@sed -e '/__REPLACE__/r$<' -e '/__REPLACE__/d' $(TOP) >$@
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

all-docs: all-bcc all-microcoreutils


### Brainlet C Compiler
bcc-man-pages=https://raw.githubusercontent.com/Benni3D/bcc/master/src

all-bcc: sites/bcc.1.html

# Generate bcc.1.html from bcc.1.html.in
sites/bcc.1.html: .cache/bcc.1.html.in $(TOP)
	@echo Generating \'$@\'
	@mkdir -p sites
	@sed -e '/__REPLACE__/r$<' -e '/__REPLACE__/d' $(TOP) >$@
	@$(UPLOAD) $@

# Generate bcc.1.html.in from bcc.1
.cache/bcc.1.html.in: .cache/bcc.1 scripts/gen_bcc.sh
	@sh scripts/gen_bcc.sh >$@

# Download bcc.1
.cache/bcc.1:
	@echo Downloading \'$@\'
	@mkdir -p .cache
	@curl $(bcc-man-pages)/bcc.1 >$@ 2>/dev/null

clean-bcc:
	rm -f sites/bcc.1.html .cache/bcc.1.html.in .cache/bcc.1


### Microcoreutils
mc-man-pageurl=https://raw.githubusercontent.com/Benni3D/microcoreutils/master/doc
mc-man-pages=$(shell grep -v '^\s*#' $(templatesdir)/microcoreutils.lst)
mc-gen-pages=$(patsubst %,sites/mc-%.html,$(mc-man-pages))

all-microcoreutils: sites/mc-summary.html $(mc-gen-pages) $(templatesdir)/microcoreutils.lst

## Summary page

# Generate mc-summary.html from mc-summary.html.in
sites/mc-summary.html: .cache/mc-summary.html.in $(TOP)
	@echo Generating \'$@\'
	@mkdir -p sites
	@sed -e '/__REPLACE__/r$<' -e '/__REPLACE__/d' $(TOP) >$@
	@$(UPLOAD) $@

# Generate mc-summary.html.in from mc-summary.html.lst
.cache/mc-summary.html.in: .cache/mc-summary.html.lst $(templatesdir)/mc-summary.html
	@sed -e '/__LINKS__/r$<' -e '/__LINKS__/d' $(templatesdir)/mc-summary.html >$@


# Generate mc-summary.html.lst from microcoreutils.lst
.cache/mc-summary.html.lst: $(templatesdir)/microcoreutils.lst scripts/gen_mclist.sh
	@mkdir -p .cache
	@sh scripts/gen_mclist.sh $< >$@
	

## Individual pages

# Generate %.html from %.html.in
sites/mc-%.html: .cache/mc-%.html.in $(TOP)
	@echo Generating \'$@\'
	@mkdir -p sites
	@sed -e '/__REPLACE__/r$<' -e '/__REPLACE__/d' $(TOP) >$@
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

###############################################################################
#			Stories that no one should read (seriously please don't)					#
###############################################################################

## Generate stories
stories-html 	= $(patsubst %,sites/story-%.html,$(shell grep -v '^\s*#' $(templatesdir)/stories.lst))

all-stories: $(stories-html) $(templatesdir)/stories.lst

# Generate story-%.html from story-%.html.in
sites/story-%.html: .cache/story-%.html.in $(TOP)
	@echo Generating \'$@\'
	@mkdir -p sites
	@sed -e '/__REPLACE__/r$<' -e '/__REPLACE__/d' $(TOP) >$@
	@$(UPLOAD) $@

# Generate story-%.html.in from %.txt
.cache/story-%.html.in: content/stories/%.txt scripts/gen_story.sh
	@sh scripts/gen_story.sh <$< >$@

###############################################################################

.PHONY:	all reupload full-clean clean				\
			all-templates all-dirs all-static		\
			all-cats all-docs clean-bcc				\
			all-microcoreutils all-bcc all-stories
