package AliTV::Tree;

use 5.010000;
use strict;
use warnings;

use parent qw(AliTV::Base);

use Bio::TreeIO;
use Bio::Tree::TreeI;
use Bio::Tree::Node;

sub _initialize
{
    my $self = shift;

    # create storage for the tree object
    $self->{_tree} = undef;
}

sub file
{
    my $self = shift;

    $self->SUPER::file(@_);

    my $fileio  = Bio::TreeIO->new(-file => $self->{file});

    $self->{_tree} = $fileio->next_tree();

    # test if we have further trees inside the file
    if ($fileio->next_tree())
    {
	$self->_logwarn("Multiple trees seems to be present in tree file");
    }
}

1;
