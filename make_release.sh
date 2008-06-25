#! /bin/sh

make_cmd="xcodebuild -target CronniX -configuration Deployment"

$make_cmd clean
$make_cmd

./createImage.sh
