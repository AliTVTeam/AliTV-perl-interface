#!/usr/bin/env perl

use strict;
use warnings;

use AliTV;

use Getopt::Long;
use Pod::Usage;

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
    log4perl.appender.Screen.stderr  = 1
    log4perl.appender.Screen.layout = Log::Log4perl::Layout::SimpleLayout
  );

Log::Log4perl::init( \$conf );
my $logger = Log::Log4perl->get_logger();

my $yml = "";

# print a status message including a version information
printf STDERR "
***********************************************************************
*                                                                     *
*  AliTV perl interface                                               *
*                                                                     *
***********************************************************************

You are using version %s.
", $AliTV::VERSION;

my $man = 0;
my $help = 0;

GetOptions('help|?' => \$help, man => \$man) or pod2usage(2);
pod2usage(1) if ($help || @ARGV== 0);
pod2usage(-exitval => 0, -verbose => 2) if $man;

if (@ARGV == 1)
{
    $yml = shift @ARGV;
} elsif (@ARGV > 1)
{
    my $config = AliTV::get_default_settings();
    $config->{genomes} = [];

    foreach my $infile (@ARGV)
    {
	push(@{$config->{genomes}}, {name => $infile, sequence_files => [ $infile ]});
    }

    $yml = 'test.yml';

    YAML::DumpFile($yml, $config);

    $logger->info("Wrote temporary YAML file '$yml'");
}

my $obj = AliTV->new(-file => $yml);

my $output = $obj->run();

print $output;

=pod

=encoding utf8

=head1 NAME

AliTV perl interface - generates the required JSON file for AliTV

=head1 SYNOPSIS

    # complex configuration via yml file
    alitv.pl options.yml

    # OR

    # easy alternative including the generation of a yml file
    alitv.pl *.fasta

=head1 DESCRIPTION

The script creates the required JSON file to run AliTV. The output
file is required to load into the AliTV website to use AliTV for the
visualization of multiple whole genome alignments.

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

