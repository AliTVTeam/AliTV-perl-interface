use strict;
use warnings;

use Test::More;
use Test::Exception;
use File::Which;
use File::Temp;

BEGIN { use_ok('AliTV::Tree') }

can_ok( 'AliTV::Tree', qw(_ladderize) );

# import the test set trees
my %test_set = ();
while (<DATA>)
{
   chomp($_);

   my ($treename, $input, $expected) = split(/\s+/, $_);

   my ($fh, $fn) = File::Temp::tempfile();
   print $fh $input;

   $test_set{$treename} = { input => $input, expected => $expected, file => $fn };
}

# cycle through all test trees and try to ladderize them
foreach my $current_tree (keys %test_set)
{
   my $obj = new_ok('AliTV::Tree');
   lives_ok { $obj->file($test_set{$current_tree}{file}) };

   $obj->_ladderize();

   # get the tree from the object
   my $tree = $obj->{_orig_tree};
   my $tree_newick = $tree->as_text('newick');

   is($tree_newick, $test_set{$current_tree}{expected}, "Got the expected tree for set '$current_tree'");
}

done_testing;

__DATA__
TreeA ((b,((d,((g,f),e)),c)),a); (a,(b,(c,(d,(e,(f,g))))));