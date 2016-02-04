package AliTV::Genome;

use 5.010000;
use strict;
use warnings;

use parent 'AliTV::Base';

use Bio::SeqIO;

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

}

sub _store_feature
{
    my $self = shift;

    my ($feature_id, $seq_id, $start, $end, $strand, $name) = @_;

    push(@{$self->{_feature}{$feature_id}{$seq_id}}, { start => $start, end => $end, strand => $strand, name => $name });
}


sub get_chromosomes
{
    my $self = shift;

    # generate a list of sequences part of the genome
    my $ret = {};

    foreach my $id (keys %{$self->{_seq}})
    {
	$ret->{$id} = { length => $self->{_seq}{$id}{len},
			genome_id => $self->name(),
			seq => $self->{_seq}{$id}{seq}
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

1;
__END__
=pod

=cut
