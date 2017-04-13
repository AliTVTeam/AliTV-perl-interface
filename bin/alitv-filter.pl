#!/usr/bin/env perl

use warnings;
use strict;

use FindBin::Real;
use lib FindBin::Real::Bin() . '/../lib';

use AliTV;

use JSON;
use Getopt::Long;

use Pod::Usage;

my $man = 0;
my $help = 0;

my $inputfile = "-";
my $outputfile = "-";
my $filtersettings = {
    maxLinkIdentity => undef,
    minLinkIdentity => undef,
    maxLinkLength => undef,
    minLinkLength => undef,
    minSeqLength => undef,
    maxSeqLength => undef,
};
my $ignore_json_settings = 0;

GetOptions(
    'help|?' => \$help,
    'man' => \$man,
    'input=s' => \$inputfile,
    'output=s' => \$outputfile,
    'min-link-identity=f' => \$filtersettings->{minLinkIdentity},
    'max-link-identity=f' => \$filtersettings->{maxLinkIdentity},
    'max-link-length=i' => \$filtersettings->{maxLinkLength},
    'min-link-length=i' => \$filtersettings->{minLinkLength},
    'max-seq-length=i' => \$filtersettings->{maxSeqLength},
    'min-seq-length=i' => \$filtersettings->{minSeqLength},
    'ignore-json!' => \$ignore_json_settings
    ) or pod2usage(2);

pod2usage(1) if ($help);
pod2usage(-exitval => 0, -verbose => 2) if $man;

my $infh;
if ($inputfile eq "-" || $inputfile eq "")
{
    $infh = *STDIN;
} else {
    open($infh, "<", $inputfile) || die "Unable to open file '$inputfile' for reading: $!";
}

my $outfh;
if ($outputfile eq "-" || $outputfile eq "")
{
    $outfh = *STDOUT;
} else {
    open($outfh, ">", $outputfile) || die "Unable to open file '$outputfile' for writing: $!";
}

foreach my $id_value (qw(minLinkIdentity maxLinkIdentity))
{
    if (defined $filtersettings->{$id_value} && $filtersettings->{$id_value} <= 1.0)
    {
	$filtersettings->{$id_value} = $filtersettings->{$id_value}*100;
    }
}

my $json;

# read input file and parse JSON
my $indat = "";
while (<$infh>)
{
    $indat .= $_;
}

$json = decode_json $indat;

# perform simple validity check of json
die "Seems to be no AliTV json" unless (exists $json->{data});
die "Seems to be no AliTV json" unless (exists $json->{data}{features});
die "Seems to be no AliTV json" unless (exists $json->{data}{features}{link});

die "Seems to be no AliTV json" unless (exists $json->{data}{links} && ref($json->{data}{links}) eq "HASH");

die "Seems to be no AliTV json" unless (exists $json->{data}{karyo});
die "Seems to be no AliTV json" unless (exists $json->{data}{karyo}{chromosomes} && ref($json->{data}{karyo}{chromosomes}) eq "HASH");

die "Seems to be no AliTV json" unless (exists $json->{filters});
die "Seems to be no AliTV json" unless (exists $json->{filters}{links});
die "Seems to be no AliTV json" unless (exists $json->{filters}{links}{invisibleLinks} && ref($json->{filters}{links}{invisibleLinks}) eq "HASH");

foreach my $expected_key (qw(maxLinkIdentity minLinkIdentity maxLinkLength minLinkLength))
{
    die "Seems to be no AliTV json" unless (exists $json->{filters}{links}{$expected_key});
}

# write welcome message and used settings
$filtersettings = welcome_and_settings($json, $filtersettings);

# filter with settings
$json = filter($json, $filtersettings);

# finally write output JSON
print $outfh encode_json $json;

sub welcome_and_settings
{
    my ($json, $settings) = @_;

    # get the settings from the JSON
    my $json_settings = {};

    $json_settings->{maxLinkIdentity} = $json->{filters}{links}{maxLinkIdentity};
    $json_settings->{maxLinkLength} = $json->{filters}{links}{maxLinkLength};
    $json_settings->{minLinkIdentity} = $json->{filters}{links}{minLinkIdentity};
    $json_settings->{minLinkLength} = $json->{filters}{links}{minLinkLength};

    # combine json and command line settings if required
    unless ($ignore_json_settings)
    {
	foreach my $setting (qw(maxLinkIdentity maxLinkLength minLinkIdentity minLinkLength))
	{
	    # does the command line value is speciefied?
	    if (defined ($settings->{$setting}))
	    {
		# sort values by size, smaller first
		my @sorted_values = sort {$a <=> $b} ($settings->{$setting}, $json_settings->{$setting});

		# max or min value?
		if ($setting =~ /^min/)
		{
		    @sorted_values = reverse @sorted_values;
		}

		# store the value in final filter_setting
		$settings->{$setting} = shift @sorted_values;

	    } else {
		# just use the value from JSON
		$settings->{$setting} = $json_settings->{$setting};
	    }
	}
    }

    print STDERR "
***********************************************************************
*                                                                     *
*  AliTV filter script                                                *
*                                                                     *
***********************************************************************

You are using version $AliTV::VERSION

Used paramter for filtering:\n";

    foreach my $key (keys %{$settings})
    {
	if (defined $settings->{$key})
	{
	    printf STDERR "\t'%s':\t%s\n", $key, $settings->{$key};
	}
    }

    return $settings;
}

sub filter
{
    my ($json, $settings) = @_;

    # got through the chromosomes and check for their length
    my %deleted_chromosomes = ();

    foreach my $chromosome (keys %{$json->{data}{karyo}{chromosomes}})
    {
	if (
	    # Chromosome to short
	    (defined $settings->{minSeqLength} && $settings->{minSeqLength} > $json->{data}{karyo}{chromosomes}{$chromosome}{length})
	    ||
	    # Chromosome to long
	    (defined $settings->{maxSeqLength} && $settings->{maxSeqLength} < $json->{data}{karyo}{chromosomes}{$chromosome}{length})
	    )
	{
	    $deleted_chromosomes{$chromosome}++;
	    delete $json->{data}{karyo}{chromosomes}{$chromosome};
	}
    }

    # build a list of link features and how many times they are used
    my %features = ();
    foreach my $first_karyo (keys %{$json->{data}{links}})
    {
	foreach my $second_karyo (keys %{$json->{data}{links}{$first_karyo}})
	{
	    foreach my $link (keys %{$json->{data}{links}{$first_karyo}{$second_karyo}})
	    {
		my $source = $json->{data}{links}{$first_karyo}{$second_karyo}{$link}{source};
		my $target = $json->{data}{links}{$first_karyo}{$second_karyo}{$link}{target};

		$features{$source}++;
		$features{$target}++;
	    }
	}
    }

    # go through the links and check for identity and length
    foreach my $first_karyo (keys %{$json->{data}{links}})
    {
	foreach my $second_karyo (keys %{$json->{data}{links}{$first_karyo}})
	{
	    foreach my $link (keys %{$json->{data}{links}{$first_karyo}{$second_karyo}})
	    {
		my $source = $json->{data}{links}{$first_karyo}{$second_karyo}{$link}{source};
		my $target = $json->{data}{links}{$first_karyo}{$second_karyo}{$link}{target};

		my ($link_source_len, $link_target_len) = (0, 0);

		if (exists $json->{data}{features}{link}{$source})
		{
		    $link_source_len = abs($json->{data}{features}{link}{$source}{start}-$json->{data}{features}{link}{$source}{end});
		}

		if (exists $json->{data}{features}{link}{$target})
		{
		    $link_target_len = abs($json->{data}{features}{link}{$target}{start}-$json->{data}{features}{link}{$target}{end});
		}

		my $link_len = ($link_source_len <= $link_target_len) ? $link_source_len : $link_target_len;

		if (
		    # Identity to small
		    (defined $settings->{minLinkIdentity} && $settings->{minLinkIdentity} > $json->{data}{links}{$first_karyo}{$second_karyo}{$link}{identity})
		    ||
		    # Identity to large
		    (defined $settings->{maxLinkIdentity} && $settings->{maxLinkIdentity} < $json->{data}{links}{$first_karyo}{$second_karyo}{$link}{identity})
		    ||
		    # Link to small
		    (defined $settings->{minLinkLength} && $settings->{minLinkLength} > $link_len)
		    ||
		    # Link to large
		    (defined $settings->{maxLinkLength} && $settings->{maxLinkLength} < $link_len)
		    ||
		    # Link is hidden
		    (exists $json->{filters}{links}{invisibleLinks}{$link})
		    ||
		    # Source chromosome deleted
		    (! exists $json->{data}{karyo}{chromosomes}{$json->{data}{features}{link}{$source}{karyo}})
		    ||
		    # Target chromosome deleted
		    (! exists $json->{data}{karyo}{chromosomes}{$json->{data}{features}{link}{$target}{karyo}})
		    )
		{
		    # decrement the feature counter and if reached 0 delete the feature
		    foreach my $type ($source,$target)
		    {
			$features{$type}-- unless ($features{$type} == 0);

			# Get the chromosome to check if it still exists
			my $chromosome = $json->{data}{features}{link}{$type}{karyo};

			if (($features{$type} == 0) || (! exists $json->{data}{karyo}{chromosomes}{$chromosome}))
			{
			    delete $json->{data}{features}{link}{$type};
			    $features{$type} = 0;
			}
		    }

		    delete $json->{data}{links}{$first_karyo}{$second_karyo}{$link};
		}
	    }
	}
    }

    # finally write the new filter values inside the json
    foreach my $parameter (qw(maxLinkIdentity minLinkIdentity maxLinkLength minLinkLength))
    {
	if (defined $settings->{$parameter})
	{
	    $json->{filters}{links}{$parameter} = $settings->{$parameter};
	}
    }

    return $json;
}

=pod

=encoding utf8

=head1 NAME

AliTV filter - filters AliTV JSON files for postprocessing

=head1 SYNOPSIS

    # Filter input file based on settings in JSON
    alitv-filter.pl --input in.json --output out.json

    # Filter input file based on settings in JSON in combination with
    # the command line settings
    alitv-filter.pl --input in.json --output out2.json --min-link-length 10000 --min-link-identity 90%

    # Filter input file based the command line settings and ignoring
    # JSON settings
    alitv-filter.pl --input in.json --output out3.json --ignore-json --min-link-length 10000 --min-link-identity 90%


=head1 DESCRIPTION

The script filters AliTV JSON files for postprocessing.

=head1 OPTIONS

=over 4

=item C<--help|?|man>  Help

Shows description of this programs, its usage, and its parameters/options.

=item --input  Input file

The name of the input file. Default value is input from STDIN which
might be switched on by C<--input ->.

=item --output   Output file

The name of the output file. Default value is output to STDOUT which
might be switched on by C<--output ->.

=item C<--min-link-identity>/C<--max-lin-identity>   Minimum/Maximum identity for Links

Specifies the minimal or maximum identity value for links. A float is
expected. Numbers greater than 1 will be handled as percentage values,
values up to 1.0 will be multiplied by 100 due to a fraction instead
of a percentage value is assumed.

=item C<--min-link-length>/C<--max-link-length>   Minimum/Maximum length for Links

Specifies the minimal or maximum length for links. A integer is
expected and specifies the length in nucleotids.

=item C<--min-seq-length>/C<--max-seq-length>   Minimum/Maximum length for chromosomes

Specifies the minimal or maximum length for chromosomes. A integer is
expected and specifies the length in nucleotids.

=item C<--ignore-json> Ignore settings in JSON file

Speciefies if the current settings from the JSON should be ignored,
otherwise a combination of the limits inside the JSON file and the
command line parameters will be used for filtering.

=back

=head1 AUTHOR

Frank FE<246>rster E<lt>foersterfrank@gmx.deE<gt>

=head1 SEE ALSO

=over 4

=item *
L<AliTV-Demo-Page|https://alitvteam.github.io/AliTV/d3/AliTV.html>

=item *
L<AliTV-Website|https://alitvteam.github.io/AliTV/>

=item *
L<AliTV-Github-Page|https://github.com/AliTVTeam/AliTV>

=back

=cut
