package AliTV::Genome;

use 5.010000;
use strict;
use warnings;

use parent 'AliTV::Base';

sub _initialize
{
    my $self = shift;

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
