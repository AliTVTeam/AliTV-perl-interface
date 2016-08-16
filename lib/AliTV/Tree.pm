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
	$return_value = {children => [ { name => $node->id() } ] };
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

sub ladderize
{
    my $self = shift;

    $self->_ladderize(1);
}

sub _ladderize
{
    my $self = shift;

    my ($up) = @_;

    $self->_make_tree_copy();

    my $tree = $self->{_orig_tree};

    # get the root node
    my $root_old = $tree->get_root_node();
    my $root_new;

    if ($root_old->id())
    {
	$root_new = Bio::Tree::Node->new(-id => $root_old->id());
    } else {
	$root_new = Bio::Tree::Node->new();
    }

    _order_nodes($root_old, $root_new, $up);

    # create a new tree
    my $new_tree = Bio::Tree::Tree->new(-root => $root_new);

    $self->{_orig_tree} = $new_tree;

}

sub _order_nodes
{
    my ($old, $new, $up) = @_;

    if ($old->is_Leaf())
    {
	return $old;
    } else {
	my @descendents = $old->each_Descendent();

	# sort the descendents by their descendent_count
	@descendents = sort {$a->descendent_count() <=> $b->descendent_count() || $a->id() cmp $b->id() || $a->internal_id() <=> $b->internal_id() } (@descendents);

	unless (defined $up && $up)
	{
	    @descendents = reverse @descendents;
	}

	# call order_nodes for each node and delete the node afterwards
	foreach my $curr_node (@descendents)
	{
	    my $node_new;
	    if ($curr_node->id())
	    {
		$node_new = Bio::Tree::Node->new(-id => $curr_node->id());
	    } else {
		$node_new = Bio::Tree::Node->new();
	    }

	    $new->add_Descendent($node_new);

	    _order_nodes($curr_node, $node_new, $up);
	}
    }
}

sub get_genome_order
{
    my $self = shift;
}

sub check_4_leaf_nodes
{
    my $self = shift;
    my @leaf_ids = @_;

    # I am using a the first bit to distinguish between required leafs
    # (bit #0) and the existing leafs (bit #1)
    my %flags = ();

    # go through the expected @leaf_ids and set the bit #0 meaning set
    # the value to 0
    foreach my $species (@leaf_ids)
    {
	$flags{$species} = 1;
    }

    # go through the existing leafs and set the bit #1 meaning or 2 to
    # an existing value
    foreach my $species (map {$_->id() } $self->{_tree}->get_leaf_nodes())
    {
	$flags{$species} |= 2;
    }

    # finally we have three different possibilities:
    # 1) value equals 1 meaning we miss the id inside the tree --> exception
    # 2) value equals 2 meaning we have a id not required in our tree --> warning
    # 3) value equals 3 meaning the id is present and required --> everything is fine

    # first do we need to die?
    my @need_an_exception = grep { $flags{$_} == 1 } (keys %flags);

    if (@need_an_exception)
    {
	$self->_logdie("Required species are not present in the given species set. Missing ids: ".join(", ", @need_an_exception));
    }

    # second do we have not required ids?
    my @need_a_warning = grep { $flags{$_} == 2 } (keys %flags);

    if (@need_a_warning)
    {
	$self->_logwarn("Tree contains species which are not required! Ignoring! Ids: ".join(", ", @need_a_warning));
    }

    return 1;
}

1;
