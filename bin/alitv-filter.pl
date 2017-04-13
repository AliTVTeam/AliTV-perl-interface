#!/usr/bin/env perl

use warnings;
use strict;

use JSON;
use Getopt::Long;

my $inputfile = "-";
my $outputfile = "-";
my $filtersettings = {
    maxLinkIdentity => undef,
    minLinkIdentity => undef,
    maxLinkLength => undef,
    minLinkLength => undef,
};

GetOptions(
    'input=s' => \$inputfile,
    'output=s' => \$outputfile,
    'min-link-identity=f' => \$filtersettings->{minLinkIdentity},
    'max-link-identity=f' => \$filtersettings->{maxLinkIdentity},
    'max-link-length=i' => \$filtersettings->{maxLinkLength},
    'min-link-length=i' => \$filtersettings->{minLinkLength},
    );

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

    return $settings;
}

sub filter
{
    my ($json, $settings) = @_;
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
