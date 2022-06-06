#!/bin/sh

set -ev

# render web version (either gitbook or bs4_book are supported)
Rscript -e "bookdown::render_book('index.Rmd')"

# Lookup what other formats are supposed to be available for download, no error if not found
formats="$(grep 'download:' _output.yml || test $? = 1; )"

# if PDF is in the download list
if [[ $formats == *"pdf"* ]]; then
  # render PDF version
  Rscript -e "bookdown::render_book('index.Rmd', 'bookdown::pdf_book')"
fi

# if mobi, azw3, or kfx is in the download list, then install pre-req's & make epub, then others
if [[ $formats == *"mobi"* || $formats == *"azw3"* || $formats == *"kfx"* ]]; then
  # a brew update isn't necessary anymore, but there's no good way to install a particular version of calibre
  # brew update
  brew install --cask calibre
  # create epub first, for conversion in next steps
  Rscript --save -e "epubFile <- bookdown::render_book('index.Rmd', 'bookdown::epub_book');"
  
  if [[ $formats == *"kfx"* ]]; then
  	# Once again, there's no good way to pick which version of kindle-previewer we want...
    brew install --cask kindle-previewer
	# Install kfxlib (KFX Output) plugin (this url is always the latest version)
	# documentation: https://www.mobileread.com/forums/showthread.php?t=272407
    curl  https://plugins.calibre-ebook.com/272407.zip --output plugin.zip 
    calibre-customize -a plugin.zip
    Rscript -e 'load(file="./.Rdata"); cmd0 = paste("calibre-debug -r \"KFX Output\" -- ", epubFile,sep=""); kfxFile <- system(cmd0,intern=FALSE);'
    # Somehow the book is going into the "_book" folder, which is where we want it. Don't ask me how.
  fi

  if [[ $formats == *"mobi"* ]]; then
    Rscript -e "load(file='./.Rdata'); bookdown::calibre(epubFile, 'mobi')"
  fi

  if [[ $formats == *"azw3"* ]]; then
    Rscript -e "load(file='./.Rdata'); bookdown::calibre(epubFile, 'azw3')"
  fi

# else if epub is in the download list & it hasn't been made yet, make it
elif [[ $formats == *"epub"* ]]; then
  # render the epub
  Rscript -e "bookdown::render_book('index.Rmd', 'bookdown::epub_book')"
fi


# render ePub version
# if --includeMobi is added in the local book build, go ahead and build that, too. 
#if [ "$1" == "--includeMobi" ]; then 
#  brew install --cask calibre
#  Rscript -e "epubFile <- bookdown::render_book('index.Rmd', 'bookdown::epub_book'); bookdown::calibre(epubFile, 'mobi')"
#else
#  Rscript -e "bookdown::render_book('index.Rmd', 'bookdown::epub_book')"
#fi

# Command to create *both* epub and mobi files.
# Turned off to speed up rebuilds during testing.
# Before turning on, make sure you install Calibre first
# Rscript -e "epubFile <- bookdown::render_book('index.Rmd', 'bookdown::epub_book'); bookdown::calibre(epubFile, 'mobi')"

# Command that *only* creates epub files.
#Rscript -e "bookdown::render_book('index.Rmd', 'bookdown::epub_book')"
