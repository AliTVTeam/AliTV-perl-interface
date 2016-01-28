package AliTV::Genome;

use 5.010000;
use strict;
use warnings;

use parent 'AliTV::Base';

sub _initialize
{
    my $self = shift;

    # set the name default to empty string
    $self->{_name} = "";

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
