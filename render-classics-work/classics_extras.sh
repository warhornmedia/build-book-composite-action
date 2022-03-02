#!/bin/sh

set -ev

# Install fonts

# encrypted via: "gpg -c font1.zip"
echo NotASecret | gpg --batch --yes --passphrase-fd 0 -d --output classics-template-files/fonts/font1.zip classics-template-files/fonts/font1.zip.gpg
unzip classics-template-files/fonts/font1.zip
unzip classics-template-files/fonts/font2.zip
sudo cp -vf Calluna/Calluna-Regular.otf /Library/Fonts
sudo cp -vf LiberationSerif-Regular.ttf /Library/Fonts
sudo cp -vf LiberationSerif-BoldItalic.ttf /Library/Fonts
sudo cp -vf LiberationSerif-Bold.ttf /Library/Fonts
sudo cp -vf LiberationSerif-Italic.ttf /Library/Fonts
