#! /bin/sh

make_cmd="xcodebuild -target CronniX -buildstyle Deployment"

$make_cmd clean
$make_cmd

./createImage.sh
