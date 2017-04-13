#!/usr/bin/env perl

use strict;
use warnings;

use FindBin::Real;
use lib FindBin::Real::Bin() . '/../lib';

use AliTV;

use Getopt::Long;
use Pod::Usage;

use Log::Log4perl;

use File::Temp;
use File::Basename;

use YAML;

my $man = 0;
my $help = 0;

my ($project, $logfile, $output);
my $overwrite = 0; # keeping existing files is default

GetOptions(
    'help|?' => \$help,
    man => \$man,
    'project=s' => \$project,
    'logfile=s' => \$logfile,
    'output=s' => \$output,
    'overwrite|force!' => \$overwrite,
    ) or pod2usage(2);

pod2usage(1) if ($help || @ARGV== 0);
pod2usage(-exitval => 0, -verbose => 2) if $man;

my $yml = "";

# Check if we have a single parameter left, which needs to be a yml file
if (@ARGV == 1)
{
    $yml = shift @ARGV;

    # yml specified, therefor use the ymls basename (without suffix
    # .yml) as project name

    if ($project)
    {
	$project = fileparse($yml, qr/\Q.yml\E/i);
	warn "YML file specified, therefore the project name was overwritten by '$project'!\n";
    }
}

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

# print a status message including a version information
printf STDERR "
***********************************************************************
*                                                                     *
*  AliTV perl interface                                               *
*                                                                     *
***********************************************************************

You are using version %s.
", $AliTV::VERSION;

if (@ARGV > 1)
{
    my $config = AliTV::get_default_settings();
    $config->{genomes} = [];

    foreach my $infile (@ARGV)
    {
	push(@{$config->{genomes}}, {name => $infile, sequence_files => [ $infile ]});
    }

    $yml = $project.".yml";

    YAML::DumpFile($yml, $config);

    $logger->info("Wrote temporary YAML file '$yml'");
}

my $obj = AliTV->new(-file => $yml, -project => $project);

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
	close($fh) || die "Unable to close file '$fn': !!\n";

	# unlink the temporary file
	unlink($fn) || die "Unable to delete file '$fn': $!\n";

	$project = $fn;

	if (-e $project.".yml")
	{
	    if ($overwrite)
	    {
		warn "File '".$project.".yml' exists... But due to overwrite parameter is specified the file will be overwritten!\n";
	    } else {
		die "File '".$project.".yml' exists... Unless you specify --overwrite the file will not be overwritten!\n";
	    }
	}

    }

    unless (defined $output)
    {
	$output = $project.".json";

	if (-e $output)
	{
	    if ($overwrite)
	    {
		warn "File '$output' exists... But due to overwrite parameter is specified the file will be overwritten!\n";
	    } else {
		die "File '$output' exists... Unless you specify --overwrite the file will not be overwritten!\n";
	    }
	}
    }

    unless (defined $logfile)
    {
	$logfile = $project.".log";

	if (-e $logfile)
	{
	    warn "Log File '$logfile' exists... Log messages will be appended\n";
	}
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
    alitv.pl [OPTIONS] options.yml

    # OR

    # easy alternative including the generation of a yml file
    alitv.pl [OPTIONS] *.fasta

=head1 DESCRIPTION

The script creates the required JSON file to run AliTV. The output
file is required to load into the AliTV website to use AliTV for the
visualization of multiple whole genome alignments.

=head1 OPTIONS

=over 4

=item --project  Project name

The name of the project will be the given argument. If this parameter
was not provided, one project name will be auto generated. This will
be the base name for the log file, the yml file, and the output
file. If a YML file is provided, this value will be overwritten by the
basename of the YML file.

=item --output   Output file

The name of the output file. If non is provided, the output file name
will be based on the project name. If STDOUT should be used, please
set the output filename to C<-> via option C<alitv.pl --output ->.

=item --logfile   Log file

The name of the log file. If non is provided, the log file name will
be based on the project name.

=item --overwrite or --force   Overwrite existing project.yml or output.json files

Default behaviour is to keep existing project yml and json files. If
C<--overwrite> or C<--force> is specified, the files will be
overwritten. Overwritting can be expicitly disabled by
C<--no-overwrite> or C<--no-force> parameter.

=back

=head1 PARAMETERS

The parameters might be a single YML file or at least to sequence
files. In case a YML file is specified, the project name will be set
accordingly to the basename of the YML file (without path information
and without the .yml suffix). In case of multiple sequence files, a
YML file will be created based on the default template. The name of
the file will be given for further runs.

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
