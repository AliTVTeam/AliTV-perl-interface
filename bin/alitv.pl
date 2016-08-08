#!/usr/bin/env perl

use strict;
use warnings;

use AliTV;

use Getopt::Long;
use Pod::Usage;

use Log::Log4perl;

use File::Temp;

use YAML;

my $man = 0;
my $help = 0;

my ($project, $logfile, $output);

GetOptions(
    'help|?' => \$help,
    man => \$man,
    'project=s' => \$project,
    'logfile=s' => \$logfile,
    'output=s' => \$output,
    ) or pod2usage(2);

pod2usage(1) if ($help || @ARGV== 0);
pod2usage(-exitval => 0, -verbose => 2) if $man;

# generate a uniq project name if not specified and a log file name
# accordingly if also not specified

($project, $output, $logfile) = generate_filenames($project, $output, $logfile);

# Log4Perl configuration
my $conf = q(
    log4perl.category                  = INFO, Logfile, Screen

    log4perl.appender.Logfile          = Log::Log4perl::Appender::File
    log4perl.appender.Logfile.filename = sub { logfile(); };
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

    YAML::DumpFile($project.".yml", $config);

    $logger->info("Wrote temporary YAML file '$yml'");
}

my $obj = AliTV->new(-file => $yml);

my $outputfh;

if ($output eq "-" || $output eq "")
{
    $outputfh = *STDOUT;
} else {
    open($outputfh, ">", $output) || die "Unable to open file '$output' for writing: $!";
}

print $outputfh $obj->run();

close($outputfh) || die "Unable to close file '$output' after writing: $!";

sub generate_filenames
{
    my ($project, $output, $logfile) = @_;

    unless (defined $project)
    {
	my ($fh, $fn) = File::Temp::tempfile("autogen_XXXXXXX");
	close($fh) || die "Unable to close file '$yml': @!\n";

	$project = $fn;
    }

    unless (defined $output)
    {
	$output = $project.".json";
    }

    unless (defined $logfile)
    {
	$logfile = $project.".log";
    }

    return ($project, $output, $logfile);
}

sub logfile()
{
    if (defined $logfile)
    {
	return $logfile;
    } else {
	return "logfile.log";
    }
}

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

=head1 PARAMETERS

=over 4

=item --project  Project name

The name of the project will be the given argument. If this parameter
was not provided, one project name will be auto generated. This will
be the base name for the log file, the yml file, and the output file.

=item --output   Output file

The name of the output file. If non is provided, the output file name
will be based on the project name. If STDOUT should be used, please
set the output filename to C<-> via option C<alitv.pl --output ->.

=item --logfile   Log file

The name of the log file. If non is provided, the log file name will
be based on the project name.

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

