package AliTV;

use 5.010000;
use strict;
use warnings;

use parent 'AliTV::Base';

use YAML;
use Hash::Merge;

use AliTV::Genome;

our $VERSION = '0.1';

sub _initialize
{
    my $self = shift;

    # initialize the yml settings using the default config
    $self->{_yml_import} = $self->_get_default_settings();
    $self->{_file} = undef;
    $self->{_genomes} = {};

}

=pod

=head1 Method run

=head2

run the generation script

=cut

sub run
{
    my $self = shift;

    #################################################################
    #
    # Import genomes
    #
    #################################################################
    # Import the given genomes

    $self->_import_genomes();

    #################################################################
    #
    # Create uniq sequence names
    #
    #################################################################
    # if the names are already uniq, the sequences names will be used
    # as unique names, otherwise the sequences will be numbered to
    # generate unique names

    $self->_make_and_set_uniq_seq_names();
}

sub file
{
    my $self = shift;

    # is another parameter given?
    if (@_)
    {
	$self->{_file} = shift;

	my $default = $self->_get_default_settings();

	# try to import the YAML file
	my $settings = YAML::LoadFile($self->{_file});

	Hash::Merge::set_behavior( 'RIGHT_PRECEDENT' );
	$self->{_yml_import} = Hash::Merge::merge($default, $settings);
    }

    return $self->{_file};
}

sub _import_genomes
{

    my $self = shift;

    # check if a file attribute is set and not undef
    unless (exists $self->{_file} && defined $self->{_file})
    {
	$self->_logdie("No file attribute exists");
    }

    foreach my $curr_genome (@{$self->{_yml_import}{genomes}})
    {
	my $genome = AliTV::Genome->new(%{$curr_genome});
	# check that the genome name is not already existing

	if (exists $self->{_genomes}{$genome->name()})
	{
	    $self->_logdie(sprintf("Genome-ID '%s' is not uniq", $genome->name()));
	}

	$self->{_genomes}{$genome->name()} = $genome;
    }
}

sub _get_default_settings
{
    my $self = shift;

    # get the default YAML
    unless (exists $self->{_default_yml})
    {
	$self->{_default_yml} = join("", <DATA>);
    }

    # try to import the default YAML
    my $default = YAML::Load($self->{_default_yml});

    return $default;
}

sub _make_and_set_uniq_seq_names
{
    my $self = shift;

    # get a list of all sequence names

    my @all_seq_ids = ();

    foreach my $genome_id (sort keys %{$self->{_genomes}})
    {
	push(@all_seq_ids, map { {name => $_, genome => $genome_id} } (sort $self->{_genomes}{$genome_id}->get_seq_names()));
    }

    # check if the sequence names are uniq
    my %seen = ();

    foreach my $curr (@all_seq_ids)
    {
	$seen{$curr->{name}}++;
    }

    # if the number of keys is equal to the number of total sequences,
    # they should be uniq
    if ((keys %seen) == @all_seq_ids)
    {
	# sequence names are uniq and can be used as uniq names
	@all_seq_ids = map { {name => $_->{name}, genome => $_->{genome}, uniq_name => $_->{name}} } (@all_seq_ids);
    } else {
	# sequences names are not uniq! Therefore, generate new
	# sequence names

	my $counter = 0;

	@all_seq_ids = map { {name => $_->{name}, genome => $_->{genome}, uniq_name => "seq".$counter++ } } (@all_seq_ids);
    }

    # set the new uniq names for each genome
    foreach my $genome_id (keys %{$self->{_genomes}})
    {
	my @set_list = map { $_->{uniq_name} => $_->{name} } grep {$_->{genome} eq $genome_id } @all_seq_ids;

	$self->{_genomes}{$genome_id}->set_uniq_seq_names(@set_list);
    }

}

sub _generate_seq_set
{
    my $self = shift;

    my @seqs = ();

    # generate a list od all sequences
    foreach my $genome_id (keys %{$self->{_genomes}})
    {
	my @new_seqs = $self->{_genomes}{$genome_id}->get_sequences();

	push(@seqs, @new_seqs);
    }

    # finally, sort the sequences by id and sequence
    return sort {$a->id() cmp $b->id() || $a->seq() cmp $b->seq()} (@seqs);
    
}

1;

=pod

=head1 NAME

AliTV - Perl class for the alitv script which generates the JSON input for AliTV

=head1 SYNOPSIS

  use AliTV;

=head1 DESCRIPTION

The class AliTV implements the functionality for the alitv.pl script.

=head1 SEE ALSO

=head1 AUTHOR

Frank FE<246>ster E<lt>foersterfrank@gmx.deE<gt>

=head1 COPYRIGHT AND LICENSE

See the F<LICENCE> file for information about the licence.

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
