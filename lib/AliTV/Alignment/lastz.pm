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

    $self->_info("Created temporary folder at '$dir'");

    # create a database file
    my $db = File::Temp->new(
	TEMPLATE => 'tempXXXXX',
	SUFFIX => '.fasta',
	DIR => $dir,
	);
    my $db_fn = $db->filename();
    close($db) || $self->_logdie("Unable to close database file '$db_fn'");

    # create a query file
    my $query = File::Temp->new(
	    TEMPLATE => 'tempXXXXX',
	    SUFFIX => '.fasta',
	    DIR => $dir,
	    );
    my $query_fn = $query->filename();
    close($query) || $self->_logdie("Unable to close query file '$query_fn'");

    my $num_of_req_alignments = @seq_set+0;
    $num_of_req_alignments = int($num_of_req_alignments*($num_of_req_alignments+1)/2);
    my @alignments = ();
    $self->_info(sprintf "Starting alignment generation... (%d alignments required)", $num_of_req_alignments);

    foreach my $seq_idx (0..@seq_set-1)
    {
	# create the query file
	my $query_obj = Bio::SeqIO->new(-file => ">".$query_fn, -format => "fasta") || $self->_logdie("Unable to reopen the query file");
	my $seq = $seq_set[$seq_idx];
	$query_obj->write_seq($seq);

	# go through the sequence set and align against all sequences left
	foreach my $db_seq_idx (($seq_idx)..(@seq_set-1))
	{
	    # create the database file
	    my $db_obj = Bio::SeqIO->new(-file => ">".$db_fn, -format => "fasta") || $self->_logdie("Unable to reopen the database file");

	    # get the current seq file and rename the sequence
	    my $seq = $seq_set[$db_seq_idx];
	    my $seq_renamed = $seq->clone();

	    $seq_renamed->id("db_".$seq->id());

	    $db_obj->write_seq($seq_renamed);

	    my $aln_file = File::Temp->new(
		TEMPLATE => 'tempXXXXX',
		SUFFIX => '.maf',
		DIR => $dir,
		);
	    close($aln_file) || $self->_logdie("Unable to close alignment file");

	    my @cmd = ();
	    push(@cmd, $self->{_cmd});
	    push(@cmd, $db_fn);
	    push(@cmd, $query_fn);
	    push(@cmd, "--output=".$aln_file->filename());
	    push(@cmd, split(/ /, $self->{_parameters}));
	    $self->_debug(sprintf("Running the aligment program as: '%s'\n", join(" ", @cmd)));
	    systemx(@cmd);

	    push(@alignments, $aln_file);
	    $self->_info(sprintf "Finished %d. alignment (%d to go; %.2f %% done)", (@alignments+0), ($num_of_req_alignments-(@alignments+0)), ((@alignments+0)/$num_of_req_alignments*100));
	}
    }

    $self->_info("Finished alignment generation");

    # import all alignments
    $self->import_alignments(@alignments);

    # cleanup temporary folder
    $self->_info("Deleting temporary folder");
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
