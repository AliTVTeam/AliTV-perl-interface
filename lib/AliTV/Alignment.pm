package AliTV::Alignment;

use 5.010000;
use strict;
use warnings;

use parent 'AliTV::Base';

sub _initialize
{
    my $self = shift;

    $self->{_callback} = undef;
    $self->{_parameters} = undef;
    $self->{_program} = undef;

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
	    $self->_logdie("Callback need to be a code reference!");
	}
    }

    return $self->{_callback};

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
