package AliTV::Base;

use AliTV::Base::Version;

sub new
{
    my ($class) = @_;
    return bless {}, $class;
}

sub DESTROY
{
    my $self = shift;

    # currently nothing to do
}

sub clone
{
    my $self = shift;

    unless (ref $self)
    {
	require Carp;
	Carp::croak("Cannot clone class '$self'");
    }

    # we require the dclone function from Storable
    require Storable;
    my $deep_copy = Storable::dclone($self);
    return $deep_copy;
}

sub file
{
    my $self = shift;

    my $return_val = undef;

    # check if other arguments are given
    if (@_)
    {
	$return_val = shift;    # first parameter is the filename
	$self->{file} = $return_val;
    } elsif (exists $self->{file}) 
    {
	# return the current value if the object has a attribute 'file'
	$return_val = $self->{file};
    } else {
	# otherwise generate the attribute and assign the value undef
	$self->{file} = $return_val;
    }

    return $return_val;
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

=item * A basic destructor

=item * A basic clone method

=back

=head1 AUTHOR

Frank Foerster, E<lt>foersterfrank@gmx.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 by Frank Foerster

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10 or,
at your option, any later version of Perl 5 you may have available.


=cut
