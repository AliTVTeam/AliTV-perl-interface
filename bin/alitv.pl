#!/usr/bin/env perl

use strict;
use warnings;

use AliTV;

use Log::Log4perl;

use YAML;

# Configuration in a string ...
my $conf = q(
    log4perl.category                  = INFO, Logfile, Screen

    log4perl.appender.Logfile          = Log::Log4perl::Appender::File
    log4perl.appender.Logfile.filename = test.log
    log4perl.appender.Logfile.layout   = Log::Log4perl::Layout::PatternLayout
    log4perl.appender.Logfile.layout.ConversionPattern = [%r] %F %L %m%n

    log4perl.appender.Screen         = Log::Log4perl::Appender::Screen
    log4perl.appender.Screen.stderr  = 0
    log4perl.appender.Screen.layout = Log::Log4perl::Layout::SimpleLayout
  );

Log::Log4perl::init( \$conf );

my $yml = "";

if (@ARGV == 1)
{
    $yml = shift @ARGV;
} elsif (@ARGV > 1)
{
    my $config = {
	genomes => []
    };

    foreach my $infile (@ARGV)
    {
	push(@{$config->{genomes}}, {name => $infile, sequence_files => [ $infile ]});
    }

    $yml = 'test.yml';

    YAML::DumpFile($yml, $config);

    print "Wrote temporary YAML file '$yml'\n";
}

my $obj = AliTV->new(-file => $yml);

my $output = $obj->run();

print $output;

=pod

=encoding utf8

=head1 NAME

alitv.pl - generate the required JSON files for AliTV

=head1 SYNOPSIS

alitv.pl options.yml

=head1 DESCRIPTION

The script creates the required JSON files to run AliTV. The two
output files are required to load into the AliTV website to use AliTV
for the visualization of multiple whole genome alignments.

=head1 AUTHOR

Frank FE<246>rster E<lt>foersterfrank@gmx.deE<gt>

=head1 SEE ALSO

=over 4

=item *
L<AliTV-Demo-Page|http://bioinf-wuerzburg.github.io/AliTV/d3/AliTV.html>

=item *
L<AliTV-Website|http://bioinf-wuerzburg.github.io/AliTV/>

=item *
L<AliTV-Github-Page|https://github.com/BioInf-Wuerzburg/AliTV>


=back

=cut

__DATA__

---
# this is the default yml file
output:
    data: data.json
    conf: conf.json
    filter: filter.json
alignment:
    program: lastz
    parameter:
       - "--format=maf"
       - "--noytrim"
       - "--ambiguous=iupac"
       - "--gapped"

