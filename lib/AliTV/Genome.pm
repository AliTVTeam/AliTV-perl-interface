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
