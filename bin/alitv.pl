#!/usr/bin/env perl
package AliTV::Script;

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

__PACKAGE__->run( @ARGV ) unless caller();

sub run
{
    my $class = shift;

    my @params = @_;

    my $man = 0;
    my $help = 0;

    my ($project, $logfile, $output);
    my $overwrite = 0; # keeping existing files is default

    Getopt::Long::GetOptionsFromArray(\@params,
	'help|?' => \$help,
	man => \$man,
	'project=s' => \$project,
	'logfile=s' => \$logfile,
	'output=s' => \$output,
	'overwrite|force!' => \$overwrite,
	) or pod2usage(2);

    pod2usage(-exitval => 0, -verbose => 2) if $man;
    pod2usage(1) if ($help || @params== 0);

    my $yml = "";

    # Check if we have a single parameter left, which needs to be a yml file
    if (@params == 1)
    {
	$yml = shift @params;

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

    ($project, $output, $logfile) = generate_filenames($project, $output, $logfile, $overwrite);

    # Log4Perl configuration
    my $conf = q(
    log4perl.category                  = INFO, Logfile, Screen

    log4perl.appender.Logfile          = Log::Log4perl::Appender::File
    log4perl.appender.Logfile.filename = sub { logfile($logfile); };
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

    if (@params > 1)
    {
	my $config = AliTV::get_default_settings();
	$config->{genomes} = [];

	foreach my $infile (@params)
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

}

sub generate_filenames
{
    my ($project, $output, $logfile, $overwrite) = @_;

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
    my $logfile = shift;

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

The script creates the required JSON file for AliTV. The output
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
overwritten. Overwriting can be expicitly disabled by
C<--no-overwrite> or C<--no-force> parameter.

=back

=head1 PARAMETERS

The parameters might be a single YML file or at least two sequence
files. In case a YML file is specified, the project name will be set
accordingly to the basename of the YML file (without path information
and without the .yml suffix). In case of multiple sequence files, a
YML file will be created based on the default template. The name of
the file will be given for further runs.

=head1 Description of the YML file format

The YML file contains the whole project description. Currently, it
supports four different sections:

=head2 Section genomes

Within the genomes section, each genome has to be declared. Each
genome need to have a unique name, at least one sequence file, and
additionally can have feature definitions.

=over 4

=item *

C<name> key defines the name of the genome and has to be unique.

=item *

C<sequence_files> key contains a list of sequence files which define
the sequence(s) of the genome

=item *

C<feature_files> key contains different features. Each is defined as
a seperate key inside the <feature_files> and contains a list of files
describing the features and their locations. In the case of
genbank/gff files the name of the feature has to match the type field
(see example below).

The easiest feature annotation file format is a tab separated F<*.tsv>
file containing the following fields: sequence ID, start coordinate,
end coordinate, strand (1/-1), and a name for that feature instance.

B<IMPORTANT> Features which can not be mapped will show no error
message. This gives the opportunaty to store feature annotations for
multiple genomes inside one file, eg. all ndh genes together.

=back

In the following example two genomes with different features are
defined (first genome has no ndh, second no ycf):

    genomes:
        -
            name: Lindenbergia_philippensis
            sequence_files:
                - data/chloroset/Lindenbergia_philippensis.fasta
            feature_files:
                ycf:
                    - data/chloroset/ycf.tsv
                invertedRepeat:
                    - data/chloroset/invertedRepeat.tsv
        -
            name: Cistanche_phelypaea
            sequence_files:
                - data/chloroset/Cistanche_phelypaea.fasta
            feature_files:
                ndh:
                    - data/chloroset/ndh.tsv
                invertedRepeat:
                    - data/chloroset/invertedRepeat.tsv

=head2 Section tree

Using the C<tree> key, a single tree file can be specified, which can
be displayed next to the genomes in AliTV. The tree file must be
readable by the Bioperl TreeIO module. Prefered format is newick.

The following example defines the location of the tree file:

    tree:   data/chloroset/species.tree

=head2 Section features

This section can be used to define how features are displayed. For
each defined feature, a key with the feature name exists for which the
following keys can be defined:

=over 4

=item *

C<color> color of the feature

=item *

C<form> of the feature. Supported values are C<arrow>, C<rect>

=item *

C<height> of the feature. C<30> is the default value.

=item *

C<visible> indicates the visibility of the feature. Should be a true or false Perl value.

=back

The following example, defines the design of the C<invertedRepeat> feature and the C<ndh> feature:

    features:
        invertedRepeat:
            color: "#e7d3e2"
            form: arrow
            height: 30
            visible: 1
        ndh:
            color: "#ff006e"
            form: rect
            height: 30
            visible: 1

=head2 Section alignment

This section contains the specification of the alignment program
via the C<program> key and the parameter settings for the program
specified via a list for the C<parameter> key.

In the following example the importer for precalculated alignments is
used. The importer will import the eight given alignment files.

  alignment:
      program: importer
      parameter:
          - "data/chloroset/pregenerated_maf/tempLdMGL.maf"
          - "data/chloroset/pregenerated_maf/tempiUqZk.maf"
          - "data/chloroset/pregenerated_maf/tempRBBMe.maf"
          - "data/chloroset/pregenerated_maf/tempqPXZ7.maf"
          - "data/chloroset/pregenerated_maf/tempsYXwN.maf"
          - "data/chloroset/pregenerated_maf/tempTSbMa.maf"
          - "data/chloroset/pregenerated_maf/temp9PSge.maf"
          - "data/chloroset/pregenerated_maf/tempzWY0h.maf"

A second example uses the lastz alignment program and specifies the
parameters to call the program for alignment generation.

  alignment:
     program: lastz
     parameter:
         - "--format=maf"
         - "--noytrim"
         - "--ambiguous=iupac"
         - "--gapped"
         - "--strand=both"


=head1 CITATION

An article about AliTV has been published in PeerJ Computer Science: https://peerj.com/articles/cs-116/
Please cite this article if you use AliTV-perl-interface in your project.
Additionally the software in any specific version can be cited via its zenodo doi: https://zenodo.org/badge/latestdoi/41874017

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
