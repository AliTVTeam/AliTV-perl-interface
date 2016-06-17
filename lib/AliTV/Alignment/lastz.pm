package AliTV::Alignment::lastz;

use strict;
use warnings;

use parent 'AliTV::Alignment';

use File::Which;
use IPC::System::Simple qw(capturex systemx);
use File::Temp qw(:seekable);
use File::Path;

sub _check
{
    my $self = shift;

    # check if we are able to find lastz

    $self->{_cmd} = which("lastz");

    unless ($self->{_cmd})
    {
	$self->_logdie("Unable to find lastz");
    }
}

sub run
{
    my $self = shift;

    my @seq_set = @_;

    $self->_check();

    # first, we need to create the database file

    # create a temporary folder without cleanup
    $File::Temp::KEEP_ALL = 1;
    my $dir = File::Temp::tempdir( CLEANUP =>  0 );

    # create a temporary file
    my $db = File::Temp->new(
	TEMPLATE => 'tempXXXXX',
	SUFFIX => '.fasta',
	DIR => $dir,
	);

    # create the database file
    my $db_obj = Bio::SeqIO->new(-fh => $db, -format => "fasta");
    foreach my $seq (@seq_set)
    {
	my $seq_renamed = $seq->clone();

	$seq_renamed->id("db_".$seq->id());

	$db_obj->write_seq($seq_renamed);
    }

    my $db_file=$db->filename().'[multiple]';

    my @alignments = ();

    $self->_debug("Starting alignment generation...");

    foreach my $seq (@seq_set)
    {
	my $query = File::Temp->new(
	    TEMPLATE => 'tempXXXXX',
	    SUFFIX => '.fasta',
	    DIR => $dir,
	    );

	my $query_obj = Bio::SeqIO->new(-fh => $query, -format => "fasta");

	$query_obj->write_seq($seq);

	my $aln_file = File::Temp->new(
	    TEMPLATE => 'tempXXXXX',
	    SUFFIX => '.maf',
	    DIR => $dir,
	    );

	my $cmd = join(" ", $self->{_cmd}, ($db_file, $query->filename(), "--output=".$aln_file->filename(), split(/ /, $self->{_parameters})));
	$self->_debug($cmd);
	systemx($self->{_cmd}, ($db_file, $query->filename(), "--output=".$aln_file->filename(), split(/ /, $self->{_parameters})));

	push(@alignments, $aln_file);

	close($query) || $self->_logdie("Unable to close file");
	close($aln_file) || $self->_logdie("Unable to close file");
    }

    $self->_debug("Finished alignment generation");

    # import all alignments
    $self->import_alignments(@alignments);

    # cleanup temporary folder
    my $removed_count = File::Path::remove_tree($dir);
    $self->_debug("Removed $removed_count temporary files");
}

1;

=head1 AliTV::Alignment::lastz

AliTV::Alignment::lastz - The AliTV::Alignment class for interaction
with an alignment program

=head1 SYNOPSIS

  use AliTV::Alignment::lastz;

  # call mechanism not clear so far

=head1 DESCRIPTION

This is the AliTV::Alignment class to align a given sequence set and return the generated alignments.

=head1 METHODS

=head1 AUTHOR

Frank Foerster, E<lt>foersterfrank@gmx.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 by Frank Foerster

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10 or,
at your option, any later version of Perl 5 you may have available.


=cut
