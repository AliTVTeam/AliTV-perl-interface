package AliTV::Feature;

use parent AliTV::Base;

sub _initialize
{
    my $self = shift;

    # we want to have an empty hash for all features
    $self->{_features} = {};

    # we want to tack all imported files
    $self->{_files} = [];

    # we need to track the current feature type
    $self->{_current_feature_type} = undef;

    # and we need to track the current feature
    $self->{_current_feature_index} = undef;

    # call the overridden method
    $self->SUPER::_initialize();
}


1;

=head1 AliTV::Feature

AliTV::Feature - The AliTV class representing a features for a sequence object

=head1 SYNOPSIS

  use AliTV::Feature;

  my $seq_obj = AliTV::Feature->new(-file => 'input.gff');

=head1 DESCRIPTION

This is the AliTV class to represent features for sequence objects. The feature information can be
loaded from a file which format is supported by Bioperl.

=head1 METHODS

=head1 AUTHOR

Frank Foerster, E<lt>foersterfrank@gmx.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 by Frank Foerster

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10 or,
at your option, any later version of Perl 5 you may have available.


=cut
