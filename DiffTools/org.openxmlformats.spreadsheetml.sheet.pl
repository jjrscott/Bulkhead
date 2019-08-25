#!/usr/bin/perl -CS

use utf8;
use strict;
use Data::Dumper;
use Getopt::Long;
use List::Util qw(max);
use JSON::PP;
use Time::HiRes qw(time);
use FindBin;
use FindBin;                 # locate this script
use lib $FindBin::Bin.'/lib';
use Sidekick::File qw(read_file write_file);
use Sidekick::Colors qw(push_gray_color push_simple_color pop_color);
use Sidekick::Diff qw(diff);

my $wrappingColor = 251;

my $startTime = time;

my $shouldColorizeResults = 1;
my $linesOfContent = 10;
my $shouldPrintOptions = 0;

my %options = (
	"colors!" => \$shouldColorizeResults,
	"lines-of-content=s" => \$linesOfContent,
	"print-options!" => \$shouldPrintOptions,
);

GetOptions(%options);

if ($shouldPrintOptions)
{
	foreach my $option (sort keys %options)
	{
		my $value = $options{$option};
		$value = $$value if 'SCALAR' eq ref $value;
		printf qq(%s = %s\n), $option, $value; 
	}
	print "\n";
}

my ($localPath, $remotePath) = @ARGV;

my $textA = arrayFromFile($localPath);
my $result = $textA;
if ($remotePath)
{
	my $textB = arrayFromFile($remotePath);
	$result = diff( $textB, $textA );
}

# die Dumper($result);
# 
my @lines = split "\n", pretty_print($result);

my @shouldDisplayLines;

for (my $lineIndex=0;$lineIndex<@lines;$lineIndex++)
{
	my $line = $lines[$lineIndex];
	if ($line =~ /^[+-]/)
	{
		for (my $keepIndex=max(0, $lineIndex-$linesOfContent+1);$keepIndex<($lineIndex+$linesOfContent);$keepIndex++)
		{
			$shouldDisplayLines[$keepIndex]=1;
		}
	}
	$shouldDisplayLines[$lineIndex]=1;
}

my $hasSkippedLines=0;
for (my $lineIndex=0;$lineIndex<@lines;$lineIndex++)
{
	if ($shouldDisplayLines[$lineIndex] || !$shouldColorizeResults)
	{
		$hasSkippedLines = 0;
		my $line = $lines[$lineIndex];
		print $line;
		print "\n";
	}
	elsif (!$hasSkippedLines)
	{
		$hasSkippedLines = 1;
		if ($shouldColorizeResults)
		{
			print push_gray_color(10);
		}
		print "...";
		if ($shouldColorizeResults)
		{
			print pop_color();
		}
		print "\n";
	}
}
# print "\n";

sub pretty_print
{
# 	return Dumper(@_);
	my ($node, $depth, $prefix) = @_;
	my $content = "";
	die unless 'ARRAY' eq ref $node;
	
	
	my %columnWidth;
	my $maxColumnIndex = 0;
	
	foreach my $row (@$node)
	{
	    my $columnIndex = 0;
	    foreach my $column (@$row)
        {
            if ('MERGE' eq ref $row)
	        {
                $columnWidth{$columnIndex} = max($columnWidth{$columnIndex}, length $column->[0]);
                $columnWidth{$columnIndex} = max($columnWidth{$columnIndex}, length $column->[1]);
	        }
	        else
	        {
                $columnWidth{$columnIndex} = max($columnWidth{$columnIndex}, length $column);
	        }
            $columnIndex++;
        }
        $maxColumnIndex = max($maxColumnIndex, $columnIndex-1);
	}
	
	foreach my $row (@$node)
	{
	    if ('MERGE' eq ref $row)
	    {
	        if (defined $row->[1] && $#{$row->[1]} >= 0)
	        {
                $content .= color_string(31, "-");
                foreach my $columnIndex (0 .. $maxColumnIndex)
                {
                    my $column = $row->[1][$columnIndex];
                    $content .= color_string(37, " |") if $columnIndex;
                    $content .= color_string(31, sprintf qq( % -$columnWidth{$columnIndex}s), $column);
                }
                $content .= "\n";
	        }

	        if (defined $row->[0] && $#{$row->[0]} >= 0)
	        {
                $content .= color_string(32, "+");
                foreach my $columnIndex (0 .. $maxColumnIndex)
                {
                    my $column = $row->[0][$columnIndex];
                    $content .= color_string(37, " |") if $columnIndex;
                    $content .= color_string(32, sprintf qq( % -$columnWidth{$columnIndex}s), $column);
                }
                $content .= "\n";
	        }
	    }
	    else
	    {
	    	my $hasMerge = 0;
	    	foreach my $columnIndex (0 .. $maxColumnIndex)
            {
                my $column = $row->[$columnIndex];
                if ('MERGE' eq ref $column)
                {
                    $hasMerge = 1;
                    last;
                }
            }
            
            if ($hasMerge)
            {                
                $content .= color_string(31, "-");

                foreach my $columnIndex (0 .. $maxColumnIndex)
                {
                    my $column = $row->[$columnIndex];
                    $content .= color_string(37, " |") if $columnIndex;
                    if ('MERGE' eq ref $column)
                    {
                        $content .= color_string(31, sprintf qq( % -$columnWidth{$columnIndex}s), $column->[1]);
                    }
                    else
                    {
                        $content .= sprintf qq( % -$columnWidth{$columnIndex}s), $column;
                    }
                }
                $content .= "\n";
                
                $content .= color_string(32, "+");
	    	
                foreach my $columnIndex (0 .. $maxColumnIndex)
                {
                    my $column = $row->[$columnIndex];
                    $content .= color_string(37, " |") if $columnIndex;
                    if ('MERGE' eq ref $column)
                    {
                        $content .= color_string(32, sprintf qq( % -$columnWidth{$columnIndex}s), $column->[0]);
                    }
                    else
                    {
                        $content .= color_string(37, sprintf qq( % -$columnWidth{$columnIndex}s), $column);
                    }
                }
                $content .= "\n";

            }
            else
            {
            	$content .= " ";
	    	
                foreach my $columnIndex (0 .. $maxColumnIndex)
                {
                    my $column = $row->[$columnIndex];
                    $content .= color_string(37, " |") if $columnIndex;
                    $content .= sprintf qq( % -$columnWidth{$columnIndex}s), $column;
                }
                $content .= "\n";
            
            }
            

	    }
	}

	return $content;
}

sub arrayFromFile
{
	my ($path) = @_;
		
	my $content = join "", qx(/usr/local/bin/xlsx2csv -c utf8 -e -d "\t" -q all "$path");

    my @rows;
    foreach my $line (split /\n/, $content)
    {
        my @cells = $line =~ m~"([^\t]*)"~g;
        foreach my $cell (@cells)
        {
            $cell =~ s~""~"~g;   
        }
        push @rows, \@cells;
    }
    return \@rows;
}

sub pretty_print_string
{
    my ($valueA, $valueB) = @_;

    my $content = "";
    
    if ($valueA eq $valueB)
    {
        return $valueA;
    }
    
    if (defined $valueA)
    {
        $content .= color_string(32, $valueA);
    }
    
    if (defined $valueB)
    {
        $content .= color_string(31, $valueB);
    }

    return $content;
}

sub color_string
{
    my ($color, $string) = @_;
    
    my $content = "";
    $content .= push_simple_color($color);
    $content .= $string;
    $content .= pop_color();
    return $content;
}