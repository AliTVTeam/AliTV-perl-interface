package AliTV::Base;

use AliTV::Base::Version;

sub new
{
    my ($class) = @_;
    return bless {}, $class;
}

1;

=head1 AliTV::Base class

AliTV::Base - basic class for all all other AliTV classes

=head1 SYNOPSIS

  package AliTV::Class;
  use parent qw(AliTV::Base)

  package main;

  use AliTV::Class;

  # VERSION is already available from AliTV::Base
  print $AliTV::Class::VERSION;

=head1 DESCRIPTION

This class is the basic class for all other AliTV classes and provides
some fundamental methods and a central version numbering. Those
methods comprise:

=over 4

=item * Consistent and global version numbering

Therefore the module utilizes L<AliTV::Base::Version> to generate a
single version number for all files.

=item * A basic constructor

=back

=head1 AUTHOR

Frank Foerster, E<lt>foersterfrank@gmx.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 by Frank Foerster

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10 or,
at your option, any later version of Perl 5 you may have available.


=cut
