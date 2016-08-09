package AliTV::Alignment::template;

use strict;
use warnings;

use parent 'AliTV::Alignment';

sub _check
{
    my $self = shift;

}

sub run
{
    my $self = shift;

    my @seq_set = @_;

    $self->_check();

    # contains the list of file to import
    my @alignments = ();

    $self->_info("Finished alignment generation");

    # import all alignments
    $self->import_alignments(@alignments);
}

1;

=head1 AliTV::Alignment::template

AliTV::Alignment::template - The AliTV::Alignment class for interaction
with an alignment program

=head1 SYNOPSIS

  use AliTV::Alignment::template;

  # call mechanism not clear so far

=head1 DESCRIPTION

This is the AliTV::Alignment class to align a given sequence set and
return the generated alignments.

=head1 METHODS

=head1 AUTHOR

Frank Foerster, E<lt>foersterfrank@gmx.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 by Frank Foerster

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10 or,
at your option, any later version of Perl 5 you may have available.


=cut
