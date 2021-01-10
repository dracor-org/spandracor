#!/bin/sh

# clone dracor-org fork of BETTE
if ! [ -d ./BETTE ]; then
  git clone https://github.com/dracor-org/BETTE.git
fi
# change to dracor branch
cd ./BETTE
git checkout dracor
git pull
cd -

for f in ./BETTE/corpus/TEI/*.xml; do
  # adjust file name
  n=$(basename $f .xml \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/bette[0-9]+_//' \
    | sed 's/_/-/' \
    | sed 's/dicenta-juanjose/dicenta-juan-jose/' \
    | sed 's/valle-divinaspalabras/valle-divinas-palabras/')
  echo $n
  # add particDesc and Wikidata IDs
  # strip reduntant xmlns:* attributes inserted by saxon
  saxon $f bette2dracor.xsl \
  | sed 's/<persName xmlns:xsl="http:\/\/www\.w3\.org\/1999\/XSL\/Transform" xmlns:tei="http:\/\/www\.tei-c\.org\/ns\/1\.0"/<persName/g' \
  | xmllint --format - > tei/$n.xml
done
