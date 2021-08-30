
all: all-dirs all-static all-cats

clean:
	rm -rf sites

# Copy styles, img, vids
content-dirs	= styles img vids
sites-dirs		= $(patsubst %,sites/%,$(content-dirs))

all-dirs: $(sites-dirs)
sites/%: content/%.d
	@echo Copying \'$<\' '->' \'$@\'
	@mkdir -p sites
	@cp -r $< $@


# Generate static sites
content-static	= EG1.html			\
					  EG2.html			\
					  impressum.html	\
					  index.html		\
					  memes.html
sites-static	= $(patsubst %.html,sites/%.html,$(content-static))

all-static: $(sites-static)
sites/%.html: content/%.html template.html
	@echo Generating \'$@\'
	@mkdir -p sites
	@sed -e '/__REPLACE__/r$<' -e '/__REPLACE__/d' template.html >$@


# Generate cat images
cat-images	= $(wildcard content/img.d/Cat*.jpg)
cat-htmls 	= $(patsubst content/img.d/%.jpg,sites/%.html,$(cat-images))
cats			= Cat_3.jpg		\
				  Cat_11.jpg	\
				  Cat_1.jpg		\
				  Cat_4.jpg		\
				  Cat_5.jpg		\
				  Cat_8.jpg		\
				  Cat_9.jpg		\
				  Cat_10.jpg	\
				  Cat_12.jpg	\
				  Cat_13.jpg	\
				  Cat_14.jpg	\
				  Cat_15.jpg	\
				  Cat_7.jpg		\
				  Cat_6.jpg		\
				  Cat_2.jpg		\
				  Cat_16.jpg	\
				  Cat_17.jpg	\
				  Cat_18.jpg	\
				  Cat_19.jpg	\
				  Cat_22.jpg	\
				  Cat_20.jpg	\
				  Cat_21.jpg	\
				  Cat_24.jpg	\
				  Cat_25.jpg	\
				  Cat_27.jpg	\
				  Cat_26.jpg	\
				  Cat_23.jpg	\
				  Cat_28.jpg	\
				  Cat_29.jpg

all-cats: $(cat-htmls) sites/cat.html
sites/%.html: content/img.d/%.jpg sites/img cat-template.html template.html
	@echo Generating \'$@\'
	@sed -e 's,__CAT__,\.\./$<,'	\
		 -e "s,__STYLE__,cat,"		\
		 cat-template.html >			\
		 $@.in
	@sed -e '/__REPLACE__/r$@.in' \
		 -e '/__REPLACE__/d'			\
		 template.html	> $@
	@rm $@.in
sites/cat.html:
	
