use strict;
use warnings;

use Test::More;
use Test::Exception;
use File::Which;
use File::Temp;

BEGIN { use_ok('AliTV::Tree') }

can_ok( 'AliTV::Tree', qw(ladderize _ladderize _order_nodes) );

# import the test set trees
my %test_set = ();
while (<DATA>)
{
   chomp($_);

   my ($treename, $input, $expected, $expected_down) = split(/\s+/, $_);

   my ($fh, $fn) = File::Temp::tempfile();
   print $fh $input;

   $test_set{$treename} = { input => $input, expected => $expected, expected_down => $expected_down, file => $fn };
}

# cycle through all test trees and try to ladderize them
foreach my $current_tree (sort keys %test_set)
{
   my $obj = new_ok('AliTV::Tree');
   lives_ok { $obj->file($test_set{$current_tree}{file}) } "Object can be prepared for set '$current_tree'";

   $obj->ladderize();

   # get the tree from the object
   my $tree = $obj->{_orig_tree};
   my $tree_newick = $tree->as_text('newick');

   is($tree_newick, $test_set{$current_tree}{expected}, "Got the expected tree for set '$current_tree' upward sorted");

   $obj = new_ok('AliTV::Tree');
   lives_ok { $obj->file($test_set{$current_tree}{file}) } "Object can be prepared for set '$current_tree' II";

   $obj->_ladderize(1);

   # get the tree from the object
   $tree = $obj->{_orig_tree};
   $tree_newick = $tree->as_text('newick');

   is($tree_newick, $test_set{$current_tree}{expected}, "Got the expected tree for set '$current_tree' directly upward sorted");

   $obj = new_ok('AliTV::Tree');
   lives_ok { $obj->file($test_set{$current_tree}{file}) } "Object can be prepared for set '$current_tree' III";

   $obj->_ladderize(0);

   # get the tree from the object
   $tree = $obj->{_orig_tree};
   $tree_newick = $tree->as_text('newick');

   is($tree_newick, $test_set{$current_tree}{expected_down}, "Got the expected tree for set '$current_tree' down sorted");
}

done_testing;

__DATA__
TreeA ((b,((d,((g,f),e)),c)),a); (a,(b,(c,(d,(e,(f,g)))))); ((((((g,f),e),d),c),b),a);
TreeB ((A,E),((D,(C,(G,H))),(B,F))); ((A,E),((B,F),(D,(C,(G,H))))); (((((H,G),C),D),(F,B)),(E,A));