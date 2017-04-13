#!/usr/bin/env perl

use warnings;
use strict;

use JSON;
use Getopt::Long;

my $inputfile = "-";
my $outputfile = "-";
my $filtersettings = {};

GetOptions(
    'input=s' => \$inputfile,
    'output=s' => \$outputfile
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
