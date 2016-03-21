package AliTV;

use 5.010000;
use strict;
use warnings;

use parent 'AliTV::Base';

use YAML;
use Hash::Merge;

our $VERSION = '0.1';

sub _initialize
{
    my $self = shift;

    # initialize the yml settings using the default config
    $self->{_yml_import} = $self->_get_default_settings();

}

=pod

=head1 Method run

=head2

run the generation script

=cut

sub run
{
    my $self = shift;

    # check if a file attribute is set and not undef
    unless (exists $self->{_file} && defined $self->{_file})
    {
	$self->_logdie("No file attribute exists");
    }
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
