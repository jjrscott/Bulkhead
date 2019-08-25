#!/bin/bash

TMPFILE=`mktemp`
BASEDIR=`dirname "$0"`
mv $TMPFILE $TMPFILE.bulkhead
echo $TMPFILE.bulkhead
$BASEDIR/diff.pl $@ > $TMPFILE.bulkhead 2> $TMPFILE.bulkhead
open -b com.jjrscott.bulkhead $TMPFILE.bulkhead
