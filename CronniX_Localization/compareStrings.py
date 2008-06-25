#! /usr/bin/env python

import re, sys

fileA = sys.argv[1]
fileB = sys.argv[2]
filelist = ( fileA, fileB )

dictionaryA = {}
commentsA = {}
dictionaryB = {}
commentsB = {}

keyValue = re.compile( '"(?P<key>.+?)"[^"]*=[^"]*"(?P<value>.+)"[^"]*;' )
comment = re.compile( '/' + unichr(0) + '\*(?P<comment>.+)' + unichr(0) + '/' );
	
firstFile = 1

for file in filelist:

	print 'Reading file: ' + file
	f = open( file, 'r' )

	b = f.readlines()	

	lastComment = None

	for line in b:
		res = comment.search( line )
		if res != None:
			commentString = res.group('comment')[3:-4]
			lastComment = res.group(0)
			
		res = keyValue.search( line )
		if res != None:

			key = res.group('key')
			value = res.group('value')

			if firstFile == 1:
				dictionaryA[ key ] = value
				commentsA[ key ] = lastComment
			else:
				dictionaryB[ key ] = value
				commentsB[ key ] = lastComment
			
	firstFile = 0

print '\n'

for k, v in dictionaryA.items():
	try:
		dictionaryB[k]
	except KeyError:
		print fileB + ': missing ' + k
		

for k, v in dictionaryB.items():
	try:
		dictionaryA[k]
	except KeyError:
		print fileA + ': missing ' + k
		
