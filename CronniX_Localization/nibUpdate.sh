#!/bin/sh

usage="Usage: $0 German MainMenu.nib"

lang=$1

if [[ $lang = "" ]]; then
    echo "no language provided"
    echo $usage
    exit -1
fi

shift

nib=$1

if [[ $nib = "" ]]; then
    echo "no nib provided"
    echo $usage
    exit -1
fi


echo Updating nib \'$nib\' for language \'$lang\'

newNib=${lang}.lproj/${nib}
englishNib=English.lproj/${nib}
nibStrings=${lang}.${nib}.strings

if [[ ! -e ${lang}.lproj ]]; then
    mkdir ${lang}.lproj
fi

if [[ ! -e $nibStrings ]]; then
    echo "Creating strings..."

    # check if a localized version exists
    if [[ -e $newNib ]]; then
	nibtool -O \
	    -I ${lang}.lproj/${nib} \
	    -L $englishNib \
	    > $nibStrings 2> /dev/null
    else
	nibtool -O \
	    -L $englishNib \
	    > $nibStrings 2> /dev/null
    fi

    echo "Strings created. Update the missing translations and run '$0 $lang' again."
    open $nibStrings
    exit 0
fi


if [[ -e $nibStrings ]]; then
    # check if a localized version exists
    if [[ -e $newNib ]]; then
	echo "Merging strings with updated nib file..."

	nibBackup=${lang}.lproj/bak.${nib}
	mv ${lang}.lproj/${nib} $nibBackup
	nibtool -O \
	    -I $nibBackup \
	    -w $newNib \
	    -d $nibStrings \
	    $englishNib 2> /dev/null
    else
	echo Creating localized nib \'$newNib\'...

	nibtool -O \
	    -w $newNib \
	    -d $nibStrings \
	    $englishNib 2> /dev/null
    fi
fi