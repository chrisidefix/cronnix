#! /bin/sh

if [[ -z $VERSION ]]; then
  VERSION=$(./getVersion.py)
fi
size=10  # Mbytes
fileSystem=HFS+
volumeName=CronniX_${VERSION}
imageName=${volumeName}.dmg
resourceDirectoy="build/Deployment/CronniX.app/Contents/Resources"
fileSet[0]="build/Deployment/CronniX.app"
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

rm -f $imageName

hdiutil create $imageName -ov -fs $fileSystem -megabytes $size \
    -volname $volumeName > /dev/null 2>&1

echo Mounting $imageName

device=`hdid $imageName \
    | grep '/dev/disk[0-9]*' \
    | grep "$volumeName" \
    | cut -d ' ' -f 1`

echo Copying files

for file in "${fileSet[@]}"; do
    echo Copying $file ...
    /Developer/Tools/CpMac -r "$file" /Volumes/$volumeName
done

# create release notes link
#currentDir=$(pwd)
#cd /Volumes/$volumeName
#ln -s "CronniX.app/Contents/Resources/English.lproj/CronniX Help/#release_notes.html" "Release Notes"
#cd $currentDir

echo Image file list:
ls -l /Volumes/$volumeName
echo

echo Ejecting $imageName

hdiutil eject $device > /dev/null 2>&1

echo Compressing $imageName ...
echo

echo mv $imageName ${imageName}.2.dmg
mv $imageName ${imageName}.2.dmg

hdiutil convert ${imageName}.2.dmg -format UDCO -o ${imageName} \
    | grep "File size"
rm ${imageName}.2.dmg

echo
