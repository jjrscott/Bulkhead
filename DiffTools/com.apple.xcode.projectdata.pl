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
# 	$shouldDisplayLines[$lineIndex]=1;
}

my $hasSkippedLines=0;
for (my $lineIndex=0;$lineIndex<@lines;$lineIndex++)
{
	if ($shouldDisplayLines[$lineIndex] || !$shouldColorizeResults)
	{
		$hasSkippedLines = 0;
		my $line = $lines[$lineIndex];
		if ($shouldColorizeResults)
		{
			if ($line =~ /^\+/)
			{
				print push_simple_color(32);
			}
			elsif ($line =~ /^\-/)
			{
				print push_simple_color(31);
			}
			else
			{
				print push_simple_color(0);
			}
		}
		print $line;
		if ($shouldColorizeResults)
		{
			print pop_color();
		}
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

sub diff
{
	my ($valueA, $valueB) = @_;

	return $valueA if $valueA eq $valueB;
	
	if (ref $valueA eq ref $valueB)
	{
		if ('HASH' eq ref $valueA)
		{
			my %result;
			my %keys = (%$valueA, %$valueB);
			foreach my $key (keys %keys)
			{
				$result{$key} = diff($valueA->{$key}, $valueB->{$key});
			}
		
			return \%result;
		}
		elsif ('ARRAY' eq ref $valueA || 'STRING' eq ref $valueA || 'BINARY' eq ref $valueA)
		{
			my @results = ();
			my @diff = sdiff($valueA, $valueB);
# 			warn Dumper(\@diff);
			foreach my $result (@diff)
			{
				if ('u' eq $result->[0])
				{
					push @results, $result->[1];
				}
				elsif ('c' eq $result->[0])
				{
					push @results, diff($result->[1], $result->[2]);
				}
				elsif ('-' eq $result->[0])
				{
					push @results, diff($result->[1], undef);
				}
				elsif ('+' eq $result->[0])
				{
					push @results, diff(undef, $result->[2]);
				}
				else
				{
					die Dumper($result, \@diff);
				}
			}
			if ('STRING' eq ref $valueA)
			{
				return bless \@results, 'STRING';
			}
			elsif ('BINARY' eq ref $valueA)
			{
				return bless \@results, 'BINARY';
			}
			else
			{
				return \@results;
			}
		}
		elsif (length ref $valueA)
		{
			die ":o( ".$valueA;
		}
	}
	return bless [$valueA, $valueB], 'MERGE';
}

sub parsePlist
{
	my ($contentRef, $depth) = @_;
	
	return parseValue($contentRef, $depth);
}

sub parseArray
{
	my ($contentRef, $depth) = @_;
	
	my $content = $$contentRef;
	
	testConstant(\$content, $depth+1, "(") || return;
	
	my @array;
	
	while (my $value = parseValue(\$content, $depth+1))
	{
		testConstant(\$content, $depth+1, ",") || die;
		push @array, $value;
	}
	
	testConstant(\$content, $depth+1, ")") || return;
	
	$$contentRef = $content;
	
	return \@array;
}

sub parseDictionary
{
	my ($contentRef, $depth) = @_;
	
	my $content = $$contentRef;
	
	testConstant(\$content, $depth+1, "{") || return;
	
	my %dictionary;
	
	while (my $key = parseString(\$content, $depth+1))
	{
		testConstant(\$content, $depth+1, "=") || die;
		my $value = parseValue(\$content, $depth+1, $key);
		die Dumper($key, $value, $depth, \%dictionary, substr $content, 0, 200) if !defined $value;
		testConstant(\$content, $depth+1, ";") || die;
		$dictionary{$key} = $value;
	}
	
	testConstant(\$content, $depth+1, "}") || die Dumper($depth, \%dictionary, substr $content, 0, 200);
	
	$$contentRef = $content;
	
	return \%dictionary;
}

sub parseValue
{
	my ($contentRef, $depth, $key) = @_;
	
	foreach my $function (\&parseString, \&parseArray, \&parseDictionary, \&parseBinary)
	{
		my $value = $function->($contentRef, $depth+1, $key);
		return $value if defined $value;
	}
	return;
}

sub parseString
{
	my ($contentRef, $depth, $key) = @_;

	my $content = $$contentRef;

	skipWhitespace(\$content, $depth+1);
	my $value;
	if ($content =~ s/^"((?:\\.|[^"])*)"//)
	{
		$value = $1;
	}
	elsif ($content =~ s/^([_a-zA-Z0-9\.\/\$]+)//)
	{
		$value = $1;
	}
	else
	{
		return;
	}

	$$contentRef = $content;
	
	my @values;
	if ($value =~ m!.\\n.!)
	{
		@values = split m!(\\n)!, $value;
	}
	elsif ('LD_RUNPATH_SEARCH_PATHS' eq $key)
	{
		@values = split m!( )!, $value;
	}
	elsif (defined $key)
	{
		@values = ($value);
	}
	else
	{
		return $value;
	}
	
	return bless [grep {length} @values], 'STRING';
}

sub parseBinary
{
	my ($contentRef, $depth, $key) = @_;

	my $content = $$contentRef;

	skipWhitespace(\$content, $depth+1);
	my $value;
	if ($content =~ s/^<([A-Fa-f0-9 ]+)>//)
	{
		$value = $1;
	}
	else
	{
		return;
	}

	$$contentRef = $content;
	
	$value =~ s/ //g;
		
	return bless [$value =~ m!(..)!g], 'BINARY';
}

sub skipWhitespace
{
	my ($contentRef, $depth) = @_;

	my $content = $$contentRef;
	
	while (1)
	{
		if ($content =~ s/^([ \t\n]+)//)
		{
			redo;
		}
		
		if ($content =~ s/^(\/\/[^\n]*\n)//)
		{
			redo;
		}
		
		if ($content =~ s/^(#[^\n]*\n)//)
		{
			redo;
		}
		
		if ($content =~ s/^(\/\*.*?\*\/)//s)
		{
			redo;
		}
	
		last;
	}

	$$contentRef = $content;

	return;
}

sub testConstant
{
	my ($contentRef, $depth, $constant) = @_;
	
	my $content = $$contentRef;
	
	skipWhitespace(\$content, $depth+1);

	my $stringIndex = index $content, $constant;
	if (0 == $stringIndex)
	{
		$$contentRef = substr $content, length $constant;
		return 1;
	}
	return;
}

sub pretty_print
{
# 	return Dumper(@_);
	my ($node, $depth, $prefix) = @_;
	my $content = "";
	$content .= " " if !$depth && $shouldColorizeResults;
# 	$content .= sprintf "---%s-->", ref $node;
	if ('HASH' eq ref $node)
	{
		$content .= "{\n";
		foreach my $key (sort keys %$node)
		{
			if ('MERGE' eq ref $node->{$key})
			{
				$content .= "<<<<<<< ours\n" if !$shouldColorizeResults;

				if (defined $node->{$key}[0])
				{
					if ($shouldColorizeResults)
					{
						$content .= "+";
					}
					$content .= "  " x ($depth + 1);
					$content .= pretty_print($key, $depth+1, "+");
					$content .= qq( = );			
					$content .= pretty_print($node->{$key}[0], $depth+1, "+");
					$content .= ";\n";
				}
		
				$content .= "=======\n" if !$shouldColorizeResults;

				if (defined $node->{$key}[1])
				{
					if ($shouldColorizeResults)
					{
						$content .= "-";
					}
					$content .= "  " x ($depth + 1);
					$content .= pretty_print($key, $depth+1, "-");
					$content .= qq( = );			
					$content .= pretty_print($node->{$key}[1], $depth+1, "-");
					$content .= ";\n";
				}
		
				$content .= ">>>>>>> theirs\n" if !$shouldColorizeResults;
			}
			else
			{
				$content .= $prefix || " " if $shouldColorizeResults;
				$content .= "  " x ($depth + 1);
				$content .= pretty_print($key, $depth+1, $prefix);
				$content .= qq( = );			
				$content .= pretty_print($node->{$key}, $depth+1, $prefix);
				$content .= ";\n";
			}
		}
		$content .= $prefix || " " if $shouldColorizeResults;
		$content .= "  " x $depth;
		$content .= "}";
	}
	elsif ('ARRAY' eq ref $node)
	{
		$content .= "(";
		if (@$node)
		{
			$content .= "\n";
			foreach my $value (@$node)
			{
				if ('MERGE' eq ref $value)
				{
					$content .= "<<<<<<< ours\n" if !$shouldColorizeResults;

					if (defined $value->[0])
					{
						if ($shouldColorizeResults)
						{
							$content .= "+";
						}
						$content .= "  " x ($depth + 1);
						$content .= pretty_print($value->[0], $depth+1, "+");
						$content .= ",\n";
					}
		
					$content .= "=======\n" if !$shouldColorizeResults;

					if (defined $value->[1])
					{
						if ($shouldColorizeResults)
						{
							$content .= "-";
						}
						$content .= "  " x ($depth + 1);
						$content .= pretty_print($value->[1], $depth+1, "-");
						$content .= ",\n";
					}
		
					$content .= ">>>>>>> theirs\n" if !$shouldColorizeResults;
				}
				else
				{
					$content .= $prefix || " " if $shouldColorizeResults;
					$content .= "  " x ($depth + 1);
					$content .= pretty_print($value, $depth+1, $prefix);
					$content .= ",\n";
				}
			}
			$content .= $prefix || " " if $shouldColorizeResults;
			$content .= "  " x $depth;
		}
		$content .= ")";
	}
	elsif ('STRING' eq ref $node)
	{
		my $containsMerges = 0;
		foreach my $value (@$node)
		{
			$containsMerges = 1 if 'MERGE' eq ref $value;
		}
		
		if ($containsMerges)
		{
			$content .= "\n";
			foreach my $value (@$node)
			{
				if ('MERGE' eq ref $value)
				{
					$content .= "<<<<<<< ours\n" if !$shouldColorizeResults;

					if (defined $value->[0])
					{
						if ($shouldColorizeResults)
						{
							$content .= "+";
						}
						$content .= "  " x ($depth + 1);
						$content .= pretty_print($value->[0], $depth+1, "+");
						$content .= "\n";
					}
		
					$content .= "=======\n" if !$shouldColorizeResults;

					if (defined $value->[1])
					{
						if ($shouldColorizeResults)
						{
							$content .= "-";
						}
						$content .= "  " x ($depth + 1);
						$content .= pretty_print($value->[1], $depth+1, "-");
						$content .= "\n";
					}
		
					$content .= ">>>>>>> theirs\n" if !$shouldColorizeResults;
				}
				else
				{
					$content .= $prefix || " " if $shouldColorizeResults;
					$content .= "  " x ($depth + 1);
					$content .= pretty_print($value, $depth+1, $prefix);
					$content .= "\n";
				}
			}
			$content .= $prefix || " " if $shouldColorizeResults;
			$content .= "  " x $depth;
		}
		else
		{
			$content .= pretty_print(join("", @$node), $depth+1, $prefix);
		}
	}
	elsif ('BINARY' eq ref $node)
	{
		my $containsMerges = 0;
		foreach my $value (@$node)
		{
			$containsMerges = 1 if 'MERGE' eq ref $value;
		}
		
		if ($containsMerges)
		{
			$content .= "\n";
			
			my @subnodes;
			
			foreach my $subnode (@$node)
			{
				if (!@subnodes || 'MERGE' eq ref $subnode ||  'MERGE' eq ref $subnodes[-1])
				{
					push @subnodes, $subnode;
				}
				else
				{
					$subnodes[-1] .= $subnode;
				}
			}
			
			foreach my $value (@subnodes)
			{
				if ('MERGE' eq ref $value)
				{
					$content .= "<<<<<<< ours\n" if !$shouldColorizeResults;

					if (defined $value->[0])
					{
						if ($shouldColorizeResults)
						{
							$content .= "+";
						}
						$content .= "  " x ($depth + 1);
						$content .= "<";
						$content .= $value->[0];
						$content .= ">";
						$content .= "\n";
					}
		
					$content .= "=======\n" if !$shouldColorizeResults;

					if (defined $value->[1])
					{
						if ($shouldColorizeResults)
						{
							$content .= "-";
						}
						$content .= "  " x ($depth + 1);
						$content .= "<";
						$content .= $value->[1];
						$content .= ">";
						$content .= "\n";
					}
		
					$content .= ">>>>>>> theirs\n" if !$shouldColorizeResults;
				}
				else
				{
					$content .= $prefix || " " if $shouldColorizeResults;
					$content .= "  " x ($depth + 1);
					$content .= "<";
					$content .= join " ", $value =~ m!(.{1,8})!g;
					$content .= ">";
					$content .= "\n";
				}
			}
			$content .= $prefix || " " if $shouldColorizeResults;
			$content .= "  " x $depth;
		}
		else
		{
			$content .= "<";
			$content .= join " ", @$node;
			$content .= ">";
		}
	}
	elsif ('MERGE' eq ref $node)
	{
		die;
	}
	elsif (length ref $node)
	{
		die "Can't pretty print: ".Dumper($node);
	}
	else
	{
		if ($node =~ /^[_a-zA-Z0-9\.\/]+$/)
		{
			$content .= $node;
		}
		else
		{
			$content .= qq("$node");
		}
	}
# 	$content .= sprintf "<--%s---", ref $node;
	return $content;
}

sub arrayFromFile
{
	my ($path) = @_;
	
	my $content = read_file("UTF-8", $path);
	
	return parsePlist(\$content);
}
