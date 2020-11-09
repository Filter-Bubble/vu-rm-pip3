#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

link=$1
targetdir=$2
module=$(basename $link)

scratch=$(mktemp -d -t tmp.XXXXXXXXXX)
finish() {
  rm -rf "$scratch"
}
trap finish EXIT

mkdir -p $targetdir
cd $targetdir

wget -c -N $link
tar -xzvf $module

#for d in Alpino/*
#do
#  if [ "$d" != "Treebank" ] && [ "$d" != "TreebankTools" ] && [ "$d" != "Tokenization" ] && [ "$d" != "Generation" ]; then
#    mv $d $targetdir
#  fi
#done
#rm -rf Alpino

