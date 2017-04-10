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
    $self->{_parameters} = [];
    $self->{_program} = undef;
    $self->{_alignments} = [];
    $self->{_sequence_set} = [];

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

sub sequence_set
{
    my $self = shift;

    if (@_)
    {
	unless (ref($_[0]) eq "ARRAY")
	{
	    $self->_logdie("You need to specify an array reference to call sequence_set method");
	}

	$self->{_sequence_set} = shift;

	# generate sequence index
	for(my $i = 0; $i < @{$self->{_sequence_set}}+0; $i++)
	{
	    my $seq = $self->{_sequence_set}[$i];
	    my $name = $i;
	    if ($seq->can("display_id") && $seq->display_id() ne "")
	    {
		$name = $seq->display_id();
	    } else {
		$self->_info("Unable to call display_id() or display_id() returns an empty string");
	    }
	    $self->{_sequence_set_index}{$name} = $i;
	}
    }

    return $self->{_sequence_set};
}

sub parameters
{
    my $self = shift;

    if (@_)
    {
	if (@_ == 1 && ref($_[0]) eq "ARRAY")
	{
	    $self->{_parameters} = shift;
	} else {
	    $self->{_parameters} = \@_;
	}
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
	# we need a fallback for bioperl version not supporting format method of Bio::AlignIO::* modules
	my $format = undef;

	if ($in->can("format"))
	{
	    $format = $in->format();
	} else {
	    $format = $in->_guess_format($infile);
	}
	if ($format eq "maf")
	{
	    $need_maf_workaround = $self->_check_if_maf_fix_is_required;
	    if ($need_maf_workaround)
	    {
		$self->_info("MAF input file and buggy BioPerl detected... Therefore, workaround for revcom issue activated");
	    } else {
		$self->_info("MAF input file detected, but Bioperl is bugfree... Therefore, workaround for revcom issue is not activated");
	    }
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

		my $aligned_seq_segment = {
		    id     => $seq_id,
		    start  => $seq->start(),
		    end    => $seq->end(),
		    strand => $seq->strand(),
		    seq    => $seq->seq()
		};

		if ($need_maf_workaround)
		{
		    $self->_fix_maf_revcomp($aligned_seq_segment);
		}

		push(@seqs, $aligned_seq_segment);
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
		seqs     => \@seqs
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

sub _check_if_maf_fix_is_required
{
    my $self = shift;

    my $input='##maf version=1 scoring=lastz.v1.03.73
# lastz.v1.03.73 --format=maf --noytrim --ambiguous=iupac --gapped --strand=both
#
# hsp_threshold      = 3000
# gapped_threshold   = 3000
# x_drop             = 910
# y_drop             = 9400
# gap_open_penalty   = 400
# gap_extend_penalty = 30
#        A    C    G    T
#   A   91 -114  -31 -123
#   C -114  100 -125  -31
#   G  -31 -125  100 -114
#   T -123  -31 -114   91
a score=143511
s normal_motif_at_4455_len_1500 4455 1500 + 10000 ATTTGTAGCCGCTAGACGATTACGCGGTGCGTGCGTACCCGGGGATCTCAGCGTCCGGTTCCGGCGTGCAGTGCTGTCTCGCAGTAAGTGCATAAGACACTTATGTGTGCGGCAACCAGACGAAGAACACAAGGTGACACCGTCGTTTGTAGCATCTTTTCTGGCAATGTTGCGCTCGGCACCGAGGTGAGACCCACTACGCTGATCGTCGTAAAAGTACTGCGCAAACTGTCCGTGGGTTAATCCAAGCGTTGATTGGATATAATCCCGTTATAACAGAAAATACGGTCACTCCCGGTTAGATGTACTCTCTAGGCAAGCTTGCACCTAAAGTAATCCTGGCTCCCGGTAGTTCCGCAAAGTTCTTGGATCGGCGTTGACCCGCCCTTCGATTGATCCGTTAGGATTCACAAGTCTATTAACCCCTTGTGTACTATACGTTGCGAGTCTATAACAGACTCGCGTTCGGGTCGGAATTCCGCTAAGAGCCTCCGGTCACATACGAACATACTATGGTGGGATTGCGGCCAGCATGGACGGGAGAAGGCTAAGATTTGCGTTACATTATGCCTCCTCACGTTGTATTAGTACCGTCACCCGCCCATAGCTGAGTACTGCCTAGACTGACTCGACGGGCCGAGGCCCCTACCAAAAGTACCGTTGCGCCGCAAGTCGATACCTGGGTACGCAGGGTGGGGCGTACGGAAGCTCATTCTGAATTTCCAAGACACTTGCGCACACCCCCAGCCGCGTTTACAGCCGCGGTCTGGCAGTCGCGCGTCAATGGGCCTCTATATAATACGGCGGCGTATTCATGGCACGGATTGATATTCCCTTACCGAAGTGCCCGTGGCTAGAATGTCGCACCAAAAGATGTTGAAACACATTGAGCATCGACTCACAATTACCACGTTAGAGTAACCACTTGTGAGCGGGGGTTGTCCCCATCCCTATATCAGCGCTAGTAAGGAACAACGGCACCATCTCACAAGTTCGCCTGCAGATCTTACGGACCCTAAGATAGCATTTCGCTATCTAGCTCATACAGTATTACCAGGCGTTACCTTGTGTTTGGGAGACAGAGGCCTAATATGAGTCTGTCTTACTCACGAGGACTAACCCATGACTTATACAGAATATGCGTCTGCATAACAAGTTCGACTCAGGGGTCCGCGCCGGTTACACCTAACCCTACACATCAATATCGTATTGGGTTCGGTCGTCGTAGCGTAGGCTTTGGCTTGGCCGCGCAATCATCGTCAGTTCGCTCCCCGTCGTGAGATAGCTTTTCAATTTCGTGTTTGATGATATTAGATATCCGCGGGCAGTTTGCGTTAAAGTCCTGCCGAAGCGTCCACTGCAAGCCTGCCCCGATCCAAGATTTAGCTAAATGCCTAGACAGCCGTAGCGAGTACGTTCGCTCAAACGGTCCCCGACTAGGGGGTGCTTTGCAATGAGGGACTTAGCGGAACTTATCGTGCGTGGCGTCTACGTACACAC
s reverse_complement            4455 1500 - 10000 ATTTGTAGCCGCTAGACGATTACGCGGTGCGTGCGTACCCGGGGATCTCAGCGTCCGGTTCCGGCGTGCAGTGCTGTCTCGCAGTAAGTGCATAAGACACTTATGTGTGCGGCAACCAGACGAAGAACACAAGGTGACACCGTCGTTTGTAGCATCTTTTCTGGCAATGTTGCGCTCGGCACCGAGGTGAGACCCACTACGCTGATCGTCGTAAAAGTACTGCGCAAACTGTCCGTGGGTTAATCCAAGCGTTGATTGGATATAATCCCGTTATAACAGAAAATACGGTCACTCCCGGTTAGATGTACTCTCTAGGCAAGCTTGCACCTAAAGTAATCCTGGCTCCCGGTAGTTCCGCAAAGTTCTTGGATCGGCGTTGACCCGCCCTTCGATTGATCCGTTAGGATTCACAAGTCTATTAACCCCTTGTGTACTATACGTTGCGAGTCTATAACAGACTCGCGTTCGGGTCGGAATTCCGCTAAGAGCCTCCGGTCACATACGAACATACTATGGTGGGATTGCGGCCAGCATGGACGGGAGAAGGCTAAGATTTGCGTTACATTATGCCTCCTCACGTTGTATTAGTACCGTCACCCGCCCATAGCTGAGTACTGCCTAGACTGACTCGACGGGCCGAGGCCCCTACCAAAAGTACCGTTGCGCCGCAAGTCGATACCTGGGTACGCAGGGTGGGGCGTACGGAAGCTCATTCTGAATTTCCAAGACACTTGCGCACACCCCCAGCCGCGTTTACAGCCGCGGTCTGGCAGTCGCGCGTCAATGGGCCTCTATATAATACGGCGGCGTATTCATGGCACGGATTGATATTCCCTTACCGAAGTGCCCGTGGCTAGAATGTCGCACCAAAAGATGTTGAAACACATTGAGCATCGACTCACAATTACCACGTTAGAGTAACCACTTGTGAGCGGGGGTTGTCCCCATCCCTATATCAGCGCTAGTAAGGAACAACGGCACCATCTCACAAGTTCGCCTGCAGATCTTACGGACCCTAAGATAGCATTTCGCTATCTAGCTCATACAGTATTACCAGGCGTTACCTTGTGTTTGGGAGACAGAGGCCTAATATGAGTCTGTCTTACTCACGAGGACTAACCCATGACTTATACAGAATATGCGTCTGCATAACAAGTTCGACTCAGGGGTCCGCGCCGGTTACACCTAACCCTACACATCAATATCGTATTGGGTTCGGTCGTCGTAGCGTAGGCTTTGGCTTGGCCGCGCAATCATCGTCAGTTCGCTCCCCGTCGTGAGATAGCTTTTCAATTTCGTGTTTGATGATATTAGATATCCGCGGGCAGTTTGCGTTAAAGTCCTGCCGAAGCGTCCACTGCAAGCCTGCCCCGATCCAAGATTTAGCTAAATGCCTAGACAGCCGTAGCGAGTACGTTCGCTCAAACGGTCCCCGACTAGGGGGTGCTTTGCAATGAGGGACTTAGCGGAACTTATCGTGCGTGGCGTCTACGTACACAC
';

    open(my $fh, "<", \$input) || $self->_logdie("Unable to create filehandle");
    my $in = Bio::AlignIO->new(-fh => $fh, -format => 'maf' );

    # input contains one alignment
    my $aln = $in->next_aln();

    unless (defined $aln)
    {
	$self->_logdie("Unable to get the alignment");
    }

    my @seqs = ();
    foreach my $seq ($aln->each_seq)
    {
	push(@seqs, $seq->start());
    }


    close($fh) || $self->_logdie("Unable to close filehandle");

    @seqs = sort { $a <=> $b } @seqs;

    # if the bug still exists, the two start coordinates should be 4456
    if ($seqs[0] == 4456 && $seqs[1] == 4456)
    {
	# bug still exists
	# Workaround needed
	return 1;
    } elsif ($seqs[0] == 4046 && $seqs[1] == 4456)
    {
	# bug solved
	# No workaround needed
	return 0;
    } else {
	# unexpected condition
	$self->_logdie("Condition unexpected for MAF import");
    }
}

sub _fix_maf_revcomp
{
    my $self = shift;

    my $alignment_segment = shift;

    if ($alignment_segment->{strand} == 1)
    {
	# nothing to do
    } elsif ($alignment_segment->{strand} == -1)
    {
	unless (exists $self->{_sequence_set_index}{$alignment_segment->{id}})
	{
	    $self->_logdie("Unable to identify sequence in sequence set by name '$alignment_segment->{id}'");
	}

	my $seq = $self->sequence_set()->[$self->{_sequence_set_index}{$alignment_segment->{id}}];
	my $seq_len = $seq->length();

	my ($start, $end) = sort {$a <=> $b} ($alignment_segment->{start}, $alignment_segment->{end});

	($alignment_segment->{start}, $alignment_segment->{end}) = sort {$a <=> $b} (($seq_len-$start+1), ($seq_len-$end+1));
    }

    return ($alignment_segment->{start}, $alignment_segment->{end});
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
