package AliTV::Genome;

use 5.010000;
use strict;
use warnings;

use parent 'AliTV::Base';

use Bio::SeqIO;
use Bio::Seq;

=pod

=head2 Methods

=cut

sub _initialize
{
    my $self = shift;

    # set the name default to empty string
    $self->{_name} = "";

    # set the seq default to empty hash-ref
    $self->{_seq} = {};

    # set the feature default to empty hash-ref
    $self->{_feature} = {};

    if (@_%2!=0)
    {
	$self->_logdie("The number of arguments was odd!");
    }

    # if nothing was provided, just return
    if (@_ == 0)
    {
	return;
    }

    # else import the data

    my %params = @_;
    # check if all required parameters are given
    # - name <-- string as name for the genome

    if (exists $params{name})
    {
	$self->name($params{name});
    }

    if (exists $params{sequence_files})
    {
	my @files2import = @{$params{sequence_files}};
	foreach my $curr_file (@files2import)
	{
	    # open the file using BioPerl and extract all sequences
	    my $fileio = Bio::SeqIO->new(-file => $curr_file);

	    while (my $seq_obj = $fileio->next_seq())
	    {
		# get the required values
		my $id = $seq_obj->id();
		my $len = $seq_obj->length();
		my $seq = $seq_obj->seq();

		# check if the id already exists
		if (exists $self->{_seq}{$id})
		{
		    $self->_logdie("The sequence ID '$id' seems to be multiple times present in file '$curr_file'");
		}

		# store the value
		$self->{_seq}{$id} = { len => $len, seq => $seq };
	    }
	}
    }

    if (exists $params{feature_files})
    {
	# we have a list of annotations
	foreach my $feature_id (keys %{$params{feature_files}})
	{
	    my @files2import = @{$params{feature_files}{$feature_id}};
	    foreach my $curr_file (@files2import)
	    {
		my @features = ();

		# guess file format based on file suffix
		if ($curr_file =~ /.tsv$/) {
		    # own tsv format
		    open(FH, "<", $curr_file) || $self->_logdie("Unable to open file '$curr_file': $!");
		    while (<FH>)
		    {
			chomp;

			my ($seq_id, $start, $end, $strand, $name) = split(/\t/, $_);

			$self->_store_feature($feature_id, $seq_id, $start, $end, $strand, $name);
		    }
		    close(FH) || $self->_logdie("Unable to close file '$curr_file': $!");
		} else {

		    if ($curr_file =~ /.(?:bed|gff|gtf|interpro|ptt)$/)
		    {
			# can be handled by Bio::FeatureIO
			require Bio::FeatureIO;

			my $in  = Bio::FeatureIO->new(-file => $curr_file);
			while ( my $feature = $in->next_feature() ) {
			    push(@features, $feature);
			}

		    } else {
			# might be handled by BioSeqIO itself
			require Bio::SeqIO;

			my $fileio = Bio::SeqIO->new(-file => $curr_file);

			while (my $seq_obj = $fileio->next_seq())
			{
			    push(@features, $seq_obj->get_all_SeqFeatures());
			}
		    }
		}

		foreach my $feature (@features)
		{
		    if ($feature_id eq $feature->primary_tag())
		    {
			my $seq_id = $feature->seq_id();
			my $start = $feature->start();
			my $end = $feature->end();
			my $strand = $feature->strand();
			my $name = "";
			foreach my $tag (qw(gene Name ID))
			{
			    if ($feature->has_tag($tag))
			    {
				$name = join("_", $feature->get_tag_values($tag));
				last;
			    }
			}
			if ($name eq "")
			{
			    $name = "no name specified";
			}

			$self->_store_feature($feature_id, $seq_id, $start, $end, $strand, $name);
		    }
		}
	    }
	}
    }

}

sub _store_feature
{
    my $self = shift;

    my ($feature_id, $seq_id, $start, $end, $strand, $name) = @_;

    # ignore features for non existing sequences
    return unless ($self->seq_exists($seq_id));

    # if feature_id is a link, we need to check if a link with exactly
    # the same coordinates exists. In that case, we need to return its
    # name instead of creating a new link feature
    my @found_features = ();
    if ($feature_id eq $self->_link_feature_name())
    {
	# search the features for the same coordinates and strand
	@found_features = grep {(
	    $_->{start} == $start
	    &&
	    $_->{end} == $end
	    &&
	    $_->{strand} == $strand
	    )} (@{$self->{_feature}{$feature_id}{$seq_id}});

	if (@found_features)
	{
	    # we expect a single hit or no hit
	    if (@found_features == 1)
	    {
		$name = $found_features[0]{name};
	    } else {
		$self->_logdie("Unexpected number of link features found!");
	    }
	}

    }

    # push a new feature, if no features are found
    unless (@found_features)
    {
	push(@{$self->{_feature}{$feature_id}{$seq_id}}, { start => $start, end => $end, strand => $strand, name => $name });
    }

    return $name;
}

sub get_features
{
    my $self = shift;

    # generate a list for each feature type

    my $ret = {};

    # do I have an existing reference
    if (@_ && ref($_[0]))
    {
	$ret = $_[0];
    }

    foreach my $feat (keys %{$self->{_feature}})
    {
	foreach my $seq_id (keys %{$self->{_feature}{$feat}})
	{
	    foreach my $entry (@{$self->{_feature}{$feat}{$seq_id}})
	    {
		my ($start, $end, $strand) = ($entry->{start}, $entry->{end}, $entry->{strand});

		# if strand is +1 we need to have start coordinate < end coordinate
		if ($strand == 1 && $end < $start)
		{
		    ($start, $end) = ($end, $start);
		}

		# if strand is -1 we need to have start coordinate > end coordinate
		if ($strand == -1 && $end > $start)
		{
		    ($start, $end) = ($end, $start);
		}

		if ($feat eq $self->_link_feature_name())
		{
		    my $link_value = { karyo => $seq_id, start => $start+0, end => $end+0 };
		    $ret->{$feat}{$entry->{name}} = $link_value;
		} else {
		    # as sequences might have renamed we need to map the seq_id to the unique sequence id
		    my $mapped_seq_id = $self->_orig_id_to_uniq_id($seq_id);

		    push(@{$ret->{$feat}}, { karyo => $mapped_seq_id, name => $entry->{name}, start => $start+0, end => $end+0 });
		}
	    }
	}
    }

    return $ret;
}

=pod

=head3 C<$obj-E<gt>get_seq_names()>

=head4 I<Parameters>

none

=head4 I<Output>

Returns a list of sequence names part of the genome.

=head4 I<Description>

B<ATTENTION!!!:>The list always contains the original sequence names, even if the list is not unique for the complete set of all genomes.

=cut

sub get_seq_names
{
    my $self = shift;

    return $self->_get_orig_seq_ids();
}

sub set_uniq_seq_names
{
    my $self = shift;

    my %params = @_;

    # check if the keys are covering the whole sequence set
    my @uniq_keys = grep {$self->seq_exists($params{$_})} (keys %params);
    my @expected_seq_ids = $self->_get_orig_seq_ids();

    # make the original sequence ID covered by unique IDs unique
    my %seen = ();
    foreach (@uniq_keys) { $seen{$params{$_}}++ }

    if ((@uniq_keys != @expected_seq_ids) || ((keys %seen) != @expected_seq_ids))
    {
	$self->_logdie("Unique identifier does not cover all original identifier!");
    }

    # clean all assignments
    $self->{_uniq_ids} = {};
    $self->{_nonuniq_ids} = {};
    # and delete entries not belonging to the @expected_seq_ids
    %seen = (); foreach (@expected_seq_ids) { $seen{$_}++; }
    foreach my $curr_key (keys %{$self->{_seq}})
    {
	unless (exists ($seen{$curr_key}))
	{
	    delete $self->{_seq}{$curr_key};
	}
    }

    while (my ($uniq_seq_id, $seq_id) = each %params)
    {
	# check if the seq_id exists in $self->{_seq}
	if (exists $self->{_seq}{$seq_id})
	{
	    $self->{_uniq_ids}{$uniq_seq_id} = $seq_id;
	    $self->{_nonuniq_ids}{$seq_id} = $uniq_seq_id;
	    if ($uniq_seq_id ne $seq_id)
	    {
		$self->{_seq}{$uniq_seq_id} = $self->{_seq}{$seq_id};
	    }
	}
   }
}

sub get_sequences
{
    my $self = shift;

    # generate a list of sequences part of the genome
    my @ret = ();

    foreach my $uniq_id ($self->_get_uniq_seq_ids())
    {
	my $seq = $self->{_seq}{$uniq_id}{seq};

	my $seq_obj = Bio::Seq->new(
	    -seq => $seq,
	    -display_id => $uniq_id
	    );

	push(@ret, $seq_obj);
    }

    # sort by id followed by seq
    @ret = sort { $a->id() cmp $b->id() || $a->seq() cmp $b->seq() } (@ret);

    return @ret;
}

sub get_chromosomes
{
    my $self = shift;

    # generate a list of sequences part of the genome
    my $ret = {};

    # do I have an existing reference
    if (@_ && ref($_[0]))
    {
	$ret = $_[0];
    }

    foreach my $id ($self->_get_orig_seq_ids())
    {
	my $uniq_id = $self->_orig_id_to_uniq_id($id);

	$ret->{$uniq_id} = { length => $self->{_seq}{$id}{len}+0,
			     genome_id => $self->name(),
			     seq => $self->{_seq}{$id}{seq},
			     name => $id
	};
    }

    return $ret;
}

sub _get_seq_ids
{
    my $self = shift;
    my $what = shift;

    my @ret = ();

    if ((defined $what) && ($what eq "uniq") && (exists $self->{_uniq_ids}) && (keys %{$self->{_uniq_ids}}))
    {
	@ret = keys %{$self->{_uniq_ids}};
    } elsif ((defined $what) && ($what eq "orig"))
    {
	if (exists $self->{_nonuniq_ids} && (keys %{$self->{_nonuniq_ids}}))
	{
	    @ret = keys %{$self->{_nonuniq_ids}};
	} else {
	    @ret = keys %{$self->{_seq}};
	}
    } else {
	$self->_logdie("Use 'uniq' or 'orig' as parameter for the method _get_seq_ids and ensure, that unique names have been generated.");
    }

    return @ret;
}

sub _get_uniq_seq_ids
{
    my $self = shift;

    return $self->_get_seq_ids("uniq");
}

sub _get_orig_seq_ids
{
    my $self = shift;

    return $self->_get_seq_ids("orig");
}

sub _orig_id_to_uniq_id
{
    my $self = shift;

    my $orig_id = shift;

    if (exists $self->{_nonuniq_ids}{$orig_id})
    {
	return $self->{_nonuniq_ids}{$orig_id};
    } elsif (exists $self->{_seq}{$orig_id}) {
	return $orig_id;
    } else {
	# should die, if the mapping does not exist
	$self->_logdie("Original ID was not found!");
    }
}

sub _uniq_id_to_orig_id
{
    my $self = shift;

    my $uniq_id = shift;

    if (exists $self->{_uniq_ids}{$uniq_id})
    {
	return $self->{_uniq_ids}{$uniq_id};
    } else {
	# should die, if the mapping does not exist
	$self->_logdie("It seems that no unique ids have been generated.");
    }
}

sub name
{
    my $self = shift;

    if (@_)
    {
	$self->{_name} = shift;
    }

    return $self->{_name};
}

sub file
{
    my $self = shift;

    $self->_logdie("File should never called for AliTV::Genome");
}

sub seq_exists
{
    my $self = shift;
    my $seq_name = shift;

    my $result = undef;

    if ( exists $self->{_seq}{$seq_name} || exists $self->{_uniq_ids}{$seq_name} )
    {
	$result = 1;
    }

    return $result;
}

1;
__END__
=pod

=cut
