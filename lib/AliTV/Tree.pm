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

sub _get_maximum_tree_depth
{
    my $self = shift;

    # create a clone of the original tree
    my $tree_copy = $self->{_tree}->clone();

    # set the branch length for each node to 1
    for my $node ($tree_copy->get_nodes)
    {
	$node->branch_length(1);
    }

    # search for the maxmimum depth
    my $max_depth = 0;

    # get the depth for each node
    foreach my $leaf ($tree_copy->get_leaf_nodes())
    {
	if ($leaf->depth() > $max_depth)
	{
	    $max_depth = $leaf->depth();
	}
    }

    return $max_depth;

}

1;
