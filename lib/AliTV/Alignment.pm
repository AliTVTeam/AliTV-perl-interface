package AliTV::Alignment;

use 5.010000;
use strict;
use warnings;

use parent 'AliTV::Base';

use Bio::AlignIO;
use Digest::MD5;
use Data::Dumper;

sub _initialize
{
    my $self = shift;

    $self->{_callback} = undef;
    $self->{_parameters} = undef;
    $self->{_program} = undef;
    $self->{_alignments} = [];

    return;
}

sub program
{
    my $self = shift;

    if (@_)
    {
	$self->{_program} = shift;
    }

    return $self->{_program};

}

sub parameters
{
    my $self = shift;

    if (@_)
    {
	$self->{_parameters} = shift;
    }

    return $self->{_parameters};

}

sub callback
{
    my $self = shift;

    if (@_)
    {
	my $callback_ref = shift;
	if (ref($callback_ref) eq "CODE")
	{
	    $self->{_callback} = $callback_ref;
	} else {
	    $self->_logdie("Callback needs to be a code reference!");
	}
    }

    return $self->{_callback};

}

sub run
{
    my $self = shift;

    $self->_logdie("Method AliTV::Alignment::run() need to be overwritten");
}

sub import_alignments
{
    my $self = shift;

    my @inputfiles = @_;

    foreach my $infile (@inputfiles)
    {
	my $in = Bio::AlignIO->new(-file => $infile );

	# this flag will be used to fix the MAF bioperl revcom issue
	# while not influcencing other alignments
	# Issue have to be fixed while link import due to I have no access to the length of the input sequences
	my $need_maf_workaround = 0;
	if ($in->format() eq "maf")
	{
	    $need_maf_workaround = 1;
	    $self->_info("MAF input file detected... Therefore workaround for revcom issue activated");
	}

	while ( my $aln = $in->next_aln ) {
	    # extract our required information

	    # first check if the alignment is flush, meaning all
	    # sequences within the alignment have the same length
	    unless ($aln->is_flush())
	    {
		$self->_logdie("Error with alignment, seems to have different length"); # uncoverable statement
	    }

	    # get the score and the identidy
	    my ($length, $score, $identity) = ($aln->length(), $aln->score(), $aln->percentage_identity());

	    # get the sequences and extract the sequence information
	    # id
	    # start
	    # end
	    # strand
	    my @seqs = ();
	    foreach my $seq ($aln->each_seq)
	    {
		my $seq_id = $seq->id();
		$seq_id =~ s/^db_//;

		push(@seqs,
		     {
			 id     => $seq_id,
			 start  => $seq->start(),
			 end    => $seq->end(),
			 strand => $seq->strand(),
			 seq    => $seq->seq()
		     }
		    );
	    }

	    # sort the seqs by id followed by start and end postion, strand and seq itself
	    @seqs = sort {
		$a->{id} cmp $b->{id}             # first alphabetically the sequence ids
		||
		    $a->{start} <=> $b->{start}   # second a lower start column
		||
		    $b->{end} <=> $a->{end}       # third a higher end column
		||
		    $a->{strand} <=> $b->{strand} # forth strand different
		||
		    $a->{seq} cmp $b->{seq}       # fifth different sequences
	    } (@seqs);

	    # store the information if they are not identical (self-hit over complete length)
	    if ($identity == 100)
	    {
		# only need to test if the alignment is identical
		my %seen_seqs = ();
		foreach my $seq (@seqs)
		{
		    $seen_seqs{join("\t", (map {$seq->{$_}} sort (keys (%{$seq}))))}++;
		}
		# if seen_seqs contains only a single key, we need to skip the entry
		if ((keys %seen_seqs)+0 == 1)
		{
		    next;
		}
	    }

	    # generate a checksum for the alignment entry to avoid multiple identical entries
	    # due to the MAF revcomp issue, a filtering here might not
	    # be sufficient and a re-filtering while link import
	    # (AliTV::Genome) is necessary
	    my $md5 = Digest::MD5->new;
	    foreach my $seq (@seqs)
	    {
		foreach my $key (sort keys %{$seq})
		{
		    $md5->add($seq->{$key});
		}
	    }
	    $md5->add($identity);
	    $md5->add($score);
	    $md5->add($length);

	    # prepare the new entry
	    my $new_alignment = {
		identity => $identity,
		score    => $score,
		len      => $length,
		md5      => $md5->hexdigest(),
		seqs     => \@seqs,
		maf_revcomp_req => $need_maf_workaround
	    };

	    # search for an entry with the same hash
	    my @collisions = grep { $_->{md5} eq $new_alignment->{md5} } (@{$self->{_alignments}});
	    if (@collisions > 0)
	    {
		# identical hash found, therefore skip the entry
		foreach my $old_alignment (@collisions)
		{
		    $self->_debug("Identical MD5 found for entries ".Dumper({new => $new_alignment, old => $old_alignment}));
		}
		next;
	    }

	    push(@{$self->{_alignments}}, $new_alignment);

	}
    }
}

sub export_to_genome
{
    my $self = shift;

    $self->_debug('Exporting alignment output into genomes by callback');

    unless (defined $self->{_callback})
    {
	$self->_logdie('Callback needs to be specified!');
    }

    foreach my $entry (@{$self->{_alignments}})
    {
	$self->{_callback}->($entry);
    }
}

sub _check
{
    my $self = shift;

    $self->_logdie('Method AliTV::Alignment::_check() need to be overwritten');
}

sub file
{
    my $self = shift;

    $self->_logdie("File should never called for AliTV::Alignment");
}

1;

=head1 AliTV::Alignment

AliTV::Alignment - The AliTV::Alignment class for interaction
with different alignment programs

=head1 SYNOPSIS

  use AliTV::Alignment::type;

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
