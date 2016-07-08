package AliTV::Genome;

use 5.010000;
use strict;
use warnings;

use parent 'AliTV::Base';

use Bio::SeqIO;
use Bio::Seq;

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
		# currently I only support tsv files
		open(FH, "<", $curr_file) || $self->_logdie("Unable to open file '$curr_file': $!");
		while (<FH>)
		{
		    chomp;

		    my ($seq_id, $start, $end, $strand, $name) = split(/\t/, $_);

		    # ignore features for non existing sequences

		    next unless (exists $self->{_seq}{$seq_id});
		    $self->_store_feature($feature_id, $seq_id, $start, $end, $strand, $name);
		}
		close(FH) || $self->_logdie("Unable to close file '$curr_file': $!");
	    }
	}
    }

}

sub _store_feature
{
    my $self = shift;

    my ($feature_id, $seq_id, $start, $end, $strand, $name) = @_;

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

		# if strand is -1 change start and end koordinate
		if ($strand == -1)
		{
		    ($start, $end) = ($end, $start);
		}

		if ($feat eq $self->_link_feature_name())
		{
		    my $link_value = { karyo => $seq_id, start => $start+0, end => $end+0 };
		    $ret->{$feat}{$entry->{name}} = $link_value;
		} else {
		    push(@{$ret->{$feat}}, { karyo => $seq_id, name => $entry->{name}, start => $start+0, end => $end+0 });
		}
	    }
	}
    }

    return $ret;
}

sub get_seq_names
{
    my $self = shift;

    # return a list of all seq names (which need to be unique anyway)
    return (keys %{$self->{_seq}});
}

sub set_uniq_seq_names
{
    my $self = shift;

    my %params = @_;

    while (my ($uniq_seq_id, $seq_id) = each %params)
    {
	# check if the seq_id exists in $self->{_seq}
	if (exists $self->{_seq}{$seq_id})
	{
	    $self->{_uniq_ids}{$uniq_seq_id} = $seq_id;
	    $self->{_nonuniq_ids}{$seq_id} = $uniq_seq_id;
	}
   }
}

sub get_sequences
{
    my $self = shift;

    # generate a list of sequences part of the genome
    my @ret = ();

    foreach my $id (keys %{$self->{_seq}})
    {
	my $uniq_id = (exists $self->{_nonuniq_ids}{$id}) ? $self->{_nonuniq_ids}{$id} : $id;
	my $seq = $self->{_seq}{$id}{seq};

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

    foreach my $id (keys %{$self->{_seq}})
    {
	my $uniq_id = (exists $self->{_nonuniq_ids}{$id}) ? $self->{_nonuniq_ids}{$id} : $id;

	$ret->{$uniq_id} = { length => $self->{_seq}{$id}{len}+0,
			     genome_id => $self->name(),
			     seq => $self->{_seq}{$id}{seq},
			     name => $id
	};
    }

    return $ret;
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

sub fix_maf_revcomp
{
    my $self = shift;

    my ($start, $end, $strand, $seq_name) = @_;

    if ($strand == 1)
    {
	# nothing to do
    } elsif ($strand == -1)
    {
	my $uniq_id = (exists $self->{_nonuniq_ids}{$seq_name}) ? $self->{_nonuniq_ids}{$seq_name} : $seq_name;

	my $seq_length = $self->{_seq}{$uniq_id}{len};

	($start, $end) = (($seq_length-$start-1), ($seq_length-$end-1));
    }

    return ($start, $end);

}


1;
__END__
=pod

=cut
