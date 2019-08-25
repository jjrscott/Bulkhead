
package Sidekick::Diff;

use utf8;
use base 'Exporter';
use Algorithm::Diff qw(sdiff);
use Scalar::Util qw(reftype blessed);

our @EXPORT_OK = qw(diff);

sub comparable
{
    my ($valueA) = @_;
    
    my $content = "";
    
    if ('HASH' eq ref $valueA)
    {
        $content .= "{";
        foreach my $key (sort keys %$valueA)
        {
            $content .= comparable($key).'='.comparable($valueA->{$key}).';';
        }		
    }
    elsif ('ARRAY' eq ref $valueA || 'STRING' eq ref $valueA || 'BINARY' eq ref $valueA)
    {
        foreach my $value (@$valueA)
        {
            $content .= comparable($value).',';
        }	
    }
    else
    {
        $content = '"'.$valueA.'"';
    }
    return $content;
}

sub diffable
{
    my ($valueA) = @_;
    
    my %references;

    if ('HASH' eq ref $valueA)
    {
	
    }
    elsif ('ARRAY' eq ref $valueA || 'STRING' eq ref $valueA || 'BINARY' eq ref $valueA)
    {
        my @results;
        foreach my $value (@$valueA)
        {
            my $comparable = comparable($value);
            $references{$comparable} = $value;
            push @results, $comparable;
        }
        return (\@results, \%references);
    }
    else
    {
        die;
    }

}

sub diff
{
	my ($valueA, $valueB) = @_;

	return $valueA if $valueA eq $valueB;
	
	if (reftype $valueA eq reftype $valueB)
	{
		if ('HASH' eq reftype $valueA)
		{
			my %result;
			my %keys = (%$valueA, %$valueB);
			foreach my $key (keys %keys)
			{
				$result{$key} = diff($valueA->{$key}, $valueB->{$key});
			}
		
			return \%result;
		}
		elsif ('ARRAY' eq reftype $valueA)
		{
			my @results = ();
			my ($diffableA, $referencesA) = diffable($valueA);
			my ($diffableB, $referencesB) = diffable($valueB);
# 			die Dumper($diffableA);
			my @diff = sdiff($diffableA, $diffableB);
			foreach my $result (@diff)
			{
			    if (0)
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
				else
				{
                    if ('u' eq $result->[0])
                    {
                        push @results, $referencesA->{$result->[1]};
                    }
                    elsif ('c' eq $result->[0])
                    {
                        push @results, diff($referencesA->{$result->[1]}, $referencesB->{$result->[2]});
                    }
                    elsif ('-' eq $result->[0])
                    {
                        push @results, diff($referencesA->{$result->[1]}, undef);
                    }
                    elsif ('+' eq $result->[0])
                    {
                        push @results, diff(undef, $referencesB->{$result->[2]});
                    }
                    else
                    {
                        die Dumper($result, \@diff);
                    }
				}
			}
			
			
            return blessed $valueA ? bless \@results, blessed $valueA : \@results;

		}
		elsif (length ref $valueA)
		{
			die ":o( ".$valueA;
		}
	}
	return bless [$valueA, $valueB], 'MERGE';
}

return 1;