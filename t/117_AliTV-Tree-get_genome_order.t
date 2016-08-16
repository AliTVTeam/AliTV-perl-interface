use strict;
use warnings;

use Test::More;
use Test::Exception;
use File::Which;
use File::Temp;

BEGIN { use_ok('AliTV::Tree') }

can_ok( 'AliTV::Tree', qw(get_genome_order) );

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
foreach my $current_tree (sort keys %test_set)
{
   my $obj = new_ok('AliTV::Tree');
   lives_ok { $obj->file($test_set{$current_tree}{file}) } "Object can be prepared for set '$current_tree'";

   $obj->ladderize();

   # get the tree from the object
   my $tree = join(",", @{$obj->get_genome_order()});

   is($tree, $test_set{$current_tree}{expected}, "Got the expected genome order for set '$current_tree'");

}

done_testing;

__DATA__
TreeA ((b,((d,((g,f),e)),c)),a); a,b,c,d,e,f,g
TreeB ((A,E),((D,(C,(G,H))),(B,F))); A,E,B,F,D,C,G,H