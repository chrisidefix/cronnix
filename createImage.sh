#! /bin/sh

VERSION=$(./getVersion.py)
size=10  # Mbytes
fileSystem=HFS+
volumeName=CronniX_${VERSION}
imageName=${volumeName}.dmg
resourceDirectoy="build/CronniX.app/Contents/Resources"
fileSet[0]="build/CronniX.app"
#fileSet[1]="Release_Notes.rtfd"
fileSet[1]="$resourceDirectoy/English.lproj/CronniX Help/release_notes.html"


#englishOnly=0
#language="English"
#for lproj in $resourceDirectoy/*.lproj; do
#	if [[ englishOnly && $lproj != $resourceDirectoy/${language}.lproj ]]; 
#	then
#		rm -r $lproj
#	fi
#done

echo
echo Creating $volumeName disk image
echo

rm $imageName

hdiutil create $imageName -ov -fs $fileSystem -megabytes $size \
    -volname $volumeName > /dev/null 2>&1

device=`hdid $imageName \
    | grep '/dev/disk[0-9]*' \
    | grep "$volumeName" \
    | cut -d ' ' -f 1`

for file in "${fileSet[@]}"; do
    echo Copying $file ...
    /Developer/Tools/CpMac -r "$file" /Volumes/$volumeName
done
echo

# create release notes link
#currentDir=$(pwd)
#cd /Volumes/$volumeName
#ln -s "CronniX.app/Contents/Resources/English.lproj/CronniX Help/#release_notes.html" "Release Notes"
#cd $currentDir

echo Image file list:
ls -l /Volumes/$volumeName
echo

hdiutil eject $device > /dev/null 2>&1

echo Compressing $imageName ...
echo

echo mv $imageName ${imageName}.orig
mv $imageName ${imageName}.orig
hdiutil convert ${imageName}.orig -format UDCO -o ${imageName} \
    | grep "File size"
rm ${imageName}.orig

echo
