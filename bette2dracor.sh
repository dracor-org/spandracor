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
  target=tei/$n.xml
  echo $n $target
  # add particDesc and Wikidata IDs
  # strip reduntant xmlns:* attributes inserted by saxon
  saxon -s:$f -xsl:bette2dracor.xsl \
  | sed 's/<persName xmlns:tei="http:\/\/www\.tei-c\.org\/ns\/1\.0" xmlns:xsl="http:\/\/www\.w3\.org\/1999\/XSL\/Transform"/<persName/g' \
    > $target
  xmlformat -i -f format.conf $target
done
