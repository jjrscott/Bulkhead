#!/usr/bin/perl -CS

use utf8;
use strict;
use Data::Dumper;
use Getopt::Long;
use List::Util qw(max);
use JSON::PP;
use Time::HiRes qw(time);
use FindBin;
use Algorithm::Diff qw(sdiff);
use FindBin;                 # locate this script
use lib $FindBin::Bin.'/lib';
use Sidekick::File qw(read_file write_file);
use Sidekick::Colors qw(push_gray_color push_simple_color pop_color);

my $wrappingColor = 251;

my $startTime = time;

my $itemContentTypeTree = qx(mdls "$ARGV[0]" -raw -name kMDItemContentTypeTree);

chomp $itemContentTypeTree;

my %itemContentTypes = map {$_, 1} $itemContentTypeTree =~ m~"([^"\n]+)"~g;

foreach my $itemContentType (sort keys %itemContentTypes)
{
    next unless -e $FindBin::Bin.'/'.$itemContentType.'.pl';
    print "$itemContentType\n";
    print "^" x length $itemContentType;
    print "\n\n";
    system $FindBin::Bin.'/'.$itemContentType.'.pl', @ARGV;
}




