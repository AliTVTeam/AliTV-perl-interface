package AliTV::Base;

use AliTV::Base::Version;
use Log::Log4perl;

sub new
{
    my $class = shift;

    my $self = {};

    bless $self, $class;

    # create a logger for the object
    $self->{logger} = Log::Log4perl->get_logger(ref($self));

    # call the private _inititialize method providing the parameters
    $self->_initialize(@_);

    if (@_%2!=0)
    {
        $self->_logdie("The number of arguments was odd!");
    }

    my %named_parameter = @_;

    foreach my $attribute (keys %named_parameter)
    {
        # ignore all key without leading dash
        my $method = $attribute;
        if ($attribute !~ /^-/)
        {
            #$self->_logdie("The attribute '$attribute' does not start with a leading dash!");
        } else {

            $method =~ s/^-//;

	    my $class = ref($self);
            if ($class->can($method))
            {
                $self->$method($named_parameter{$attribute});
            } else {
                $self->_logdie("The attribute '$method' has no setter in class '".__PACKAGE__."'");
            }
        }
    }

    return $self;
}

sub _logdie
{
    my $self = shift;
    my $msg = shift;

    $self->_logging($msg, "logcroak");
}

sub _logwarn
{
    my $self = shift;
    my $msg = shift;

    $self->_logging($msg, "logwarn");
}

sub _debug
{
    my $self = shift;
    my $msg = shift;

    $self->_logging($msg, "debug");
}

sub _info
{
    my $self = shift;
    my $msg = shift;

    $self->_logging($msg, "info");
}

sub _warn
{
    my $self = shift;
    my $msg = shift;

    $self->_logging($msg, "warn");
}

sub _error
{
    my $self = shift;
    my $msg = shift;

    $self->_logging($msg, "error");
}

sub _fatal
{
    my $self = shift;
    my $msg = shift;

    $self->_logging($msg, "fatal");
}

sub _logging
{
    my $self = shift;
    my $msg = shift;
    my $level = shift;

    unless (ref($self) &&
	    exists $self->{logger} &&
	    ref($self->{logger}) &&
	    $self->{logger}->can($level))
    {
	# without a Log::Log4perl instance we can not use its
	# functionality, therefore we need to use Carp instead
	require Carp;
	Carp::croak($msg);
    } else {
	$self->{logger}->$level($msg);
    }
}

sub _initialize
{
    my $self = shift;

    $self->_logdie("You need to overwrite the method ".__PACKAGE__."::_initialize()");
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
	# this is a class function, therefore no logger is defined,
	# use Carp instead
	require Carp;
	Carp::croak("Cannot clone class '$self'");
    }

    # CODE items can not be dcloned... Therefore delete the logger
    delete $self->{logger};

    # we require the dclone function from Storable
    require Storable;
    # clone the object
    my $deep_copy = Storable::dclone($self);

    # restore the logger object
    $deep_copy->{logger} = Log::Log4perl->get_logger(ref($deep_copy));
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

	# call the check for existing files
	$self->_file_check();
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

sub _file_check
{
    my $self = shift;

    # check if the attribute 'file' exists and is defined
    if (exists $self->{file} && defined $self->{file})
    {
	unless (-e $self->{file})
	{
	    $self->_logdie("The file '$self->{file}' does not exist!");
	}
    }
}

# This class method returns the name for link features. This can be
# used in other classes to avoid inconsistencies with link feature
# naming

sub _link_feature_name
{
    return "link";
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
