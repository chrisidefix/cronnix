#! /usr/bin/env python

from Foundation import *

plistFile = 'build/Deployment/CronniX.app/Contents/Info.plist'
key = 'CFBundleShortVersionString'

dictionary = NSMutableDictionary.dictionary()

obj = dictionary.dictionaryWithContentsOfFile_( plistFile )

print obj[key]