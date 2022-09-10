# custom-actions
Action for reproducible book builds

## v0.6 version info

- keeps files (artifacts) from failed builds for download and examination

## v0.5 version info

- r version: 4.2.0
- pandoc version: 2.18
- tinytex version: https://texlive.info/tlnet-archive/2022/05/02/tlnet/
- bookdown version: 0.26
- rmarkdown version: 2.14

## v0.2 version info

- r version: 4.1.2
- pandoc version: 2.14.2
- tinytex version: 2021.11
- bookdown version: 0.24
- rmarkdown version: 2.11

## How to use these Github Action scripts

In general, if you are building a Warhorn Classics book, you don't need to worry about these, as the correct automation is already in place. However, two of these scripts, setup-bookdown and build-book, could be useful for anybody who wants to automate building a bookdown book with consistent results and easy control over the various software versions used.

## Script details

### render-classics-work

This is a script that will do everything necessary to create a Warhorn Classics work via bookdown. Afterwards, it needs only to be deployed. 

In order, here's what it does:

1. Calls the sister action "setup-bookdown"
2. Imports the classics-template-files repo so necessary files will be available for following steps
3. Runs classics_extras.sh to perform a few classics customizations such as installing fonts
4. Calls the sister action "build-book"

Here's an example script from a Warhorn Classics book making use of version 0.2 of this action:

```
on:
  push:
     branches:
       - master
       - main

jobs:
  bookdown:
    runs-on: macos-11
    steps:
      - name: call-Render-Book
        uses: warhornmedia/custom-actions/render-classics-work@v0.2

      - name: deploy to github pages
        uses: JamesIves/github-pages-deploy-action@4.0.0
        with:
          TOKEN: ${{ secrets.GH_PAT }} # https://github.com/settings/tokens
          BRANCH: gh-pages # The branch the action should deploy to
          FOLDER: _book # The folder the action should deploy
          CLEAN: true # Automatically remove deleted files from the deploy branch
```

### setup-bookdown

This script will setup a virtual machine with all of the necessary software to build a bookdown project with default versions, but also allowing you to specify custom versions, if you want. Tagged releases (ie script versions) have software versions specified that are known to work together well. Also, leaving the version of the script unspecified will use defaults, not simply the latest of each. See above for which software versions are installed by the various script versions. 

Here is the render-classics-work action using this action:

```
name: "Render Classics work"
description: "Render a work for Warhorn Classics..."

runs: 
  using: "composite"
  steps:
      - uses: actions/checkout@v2
      - uses: warhornmedia/custom-actions/setup-bookdown@v0.2

      - name: Clone Warhorn Classics template files
        run: git clone https://github.com/warhornmedia/classics-template-files.git
        shell: bash

      - name: Add path to build script
        run: echo "${{ github.action_path }}" >> $GITHUB_PATH
        shell: bash
        
      - name: Do extra Warhorn Classics setup
        run: classics_extras.sh
        shell: bash

      - name: Build the book
        uses: warhornmedia/custom-actions/build-book@v0.2
```

### build-book

This action finds out which file formats are supposed to be available, and then installs any additional software needed before giving the commands to bookdown to render the content into those formats. If mobi, Calibre is needed. If any other Kindle version, Kindle Previewer is also needed. These installations slow the build down quite a bit. 
