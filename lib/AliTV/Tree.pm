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
    $self->_make_tree_copy();

    # set the branch length for each node to 1
    for my $node ($self->{_tree}->get_nodes)
    {
	$node->branch_length(1);
    }

    # search for the maxmimum depth
    my $max_depth = 0;

    # get the depth for each node
    foreach my $leaf ($self->{_tree}->get_leaf_nodes())
    {
	if ($leaf->depth() > $max_depth)
	{
	    $max_depth = $leaf->depth();
	}
    }

    return $max_depth;

}

sub tree_2_json_structure
{
    my $self = shift;

    my $json_structure;

    # get the root node
    my $root_node = $self->{_tree}->get_root_node();

    $json_structure = $self->_deep_scan($root_node);

    return $json_structure;
}


sub _deep_scan
{
    my $self = shift;

    my $node = shift;

    my $return_value;

    if($node->is_Leaf())
    {
	# we are done --> return a hash ref
	$return_value = { name => $node->id() };
    } else {
	# we have no leaf node, therefore
	# get a list of all descendents
	my @desc = $node->each_Descendent();

	$return_value = {};

	# call the function for each descendent and add it to the
	# return value
	foreach my $new_node (@desc)
	{
	    push(@{$return_value->{children}}, $self->_deep_scan($new_node));
	}
    }

    return $return_value;
}

sub _make_tree_copy
{
    my $self = shift;

    # check if the attribute _tree already exist and its value is defined
    unless (exists $self->{_tree} && defined $self->{_tree})
    {
	# we cannot do anything
	# print a message
	$self->_logwarn("No tree attribute is set for the object!");
	# and return
	return;
    }

    # check if the attribute _orig_tree already exist and its value is defined
    if (exists $self->{_orig_tree} && defined $self->{_orig_tree})
    {
	# than nothing is required to do
	return;
    }

    # just copy the tree from the _tree attribute to the _orig_tree attribute
    $self->{_orig_tree} = $self->{_tree}->clone();
}

sub balance_node_depth
{
    my $self = shift;

    # create a clone of the original tree if necessary
    $self->_make_tree_copy();

    my $required_depth = $self->_get_maximum_tree_depth();

    # go through all leaf nodes
    foreach my $leaf ($self->{_tree}->get_leaf_nodes())
    {
	# if the leaf depth is less than $required_depth we need to add intermediate nodes
	if ($leaf->depth() < $required_depth)
	{
	    # how many intermediate nodes are required?
	    my $num_nodes_required = $required_depth - $leaf->depth();
	    # get the parent of the node
	    my $parent = $leaf->ancestor();

	    # delete the original node
	    $self->{_tree}->remove_Node($leaf);

	    # we need to create $required_depth-1 intermediate nodes
	    for (my $i=0; $i<$num_nodes_required; $i++)
	    {
		my $node = Bio::Tree::Node->new();
		$node->branch_length(1);
		$parent->add_Descendent($node);
		$parent = $node;
	    }

	    # finally we add our original node to the end
	    $parent->add_Descendent($leaf);
	}
    }

}

1;
