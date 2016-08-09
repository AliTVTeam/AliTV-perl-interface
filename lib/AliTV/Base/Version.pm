package AliTV::Base::Version;

use 5.010000;
#use strict;
#use warnings;

use version 0.77; our $VERSION = version->declare("v0.1.12");

# The following code is from Bio::Root::Version module and try to
# handle multiple levels of inheritance and is adopted to work on
# AliTV modules
sub import {
    my $i = 0;
    my $pkg = caller($i);
    no strict 'refs';
    while ($pkg) {
        if (    $pkg =~ /^AliTV:*/
            and not defined ${$pkg . "::VERSION"}
            ) {
            ${$pkg . "::VERSION"} = $VERSION;
        }
        $pkg = caller(++$i);
    }
}

1;

__END__

=head1 AliTV::Base::Version

AliTV::Base::Version - Central version number of AliTV classes

=head1 SYNOPSIS

  package AliTV::Class;
  use parent qw(AliTV::Base)

  package main;

  use AliTV::Class;
  
  # VERSION is already available from AliTV::Base
  print $AliTV::Class::VERSION,"\n";

=head1 DESCRIPTION

This module is used by L<AliTV::Base> class to provides a central
version number of all classes derived from L<AliTV::Base>

=head1 AUTHOR

Frank Foerster, E<lt>foersterfrank@gmx.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 by Frank Foerster

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10 or,
at your option, any later version of Perl 5 you may have available.


=cut
