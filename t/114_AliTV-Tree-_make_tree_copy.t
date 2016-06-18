use strict;
use warnings;

use Test::More;
use Test::Exception;
use Test::Warnings ':all';

BEGIN { use_ok('AliTV::Tree') }

can_ok( 'AliTV::Tree', qw(_make_tree_copy) );

my $obj = new_ok('AliTV::Tree');

# here we expect to have no tree stored in the attribute _tree
my $warning = warning { $obj->_make_tree_copy() };
like(
    $warning,
    qr/No tree attribute is set for the object/,
'Expecting warning without a stored tree',
) || diag 'got warning(s) : ', explain($warning);


my $inputfile = "data/tree_a.newick";

$obj->file($inputfile);

# store the structure for later use
my $orig = $obj->tree_2_json_structure();

# call the method
$obj->_make_tree_copy();

# and check if both trees are existing and are the same
ok( exists $obj->{_orig_tree},  "An attribute _orig_tree exists" );
ok( defined $obj->{_orig_tree}, "The attribute _orig_tree is defined" );
ok( exists $obj->{_tree},       "An attribute _tree exists" );
ok( defined $obj->{_tree},      "The attribute _tree is defined" );

is_deeply( $obj->tree_2_json_structure(),
    $orig, "Both trees have the same content" );

done_testing;
