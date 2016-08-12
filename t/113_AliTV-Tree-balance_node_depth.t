use strict;
use warnings;

use Test::More;
use Test::Exception;
use File::Which;
use File::Temp;

BEGIN { use_ok('AliTV::Tree') }

can_ok( 'AliTV::Tree', qw(balance_node_depth) );

my $obj = new_ok('AliTV::Tree');

# import the expected values from __DATA__ section
my @inputfiles = <DATA>;
chomp(@inputfiles);

# test if the topology of the tree is valid, if qdist is available
my $qdist_executable = which('qdist');
my $num_tests = @inputfiles;
SKIP: {
    skip "Missing qdist program to calculate quartest distance of trees", $num_tests unless ($qdist_executable);

    foreach my $inputfile ( @inputfiles ) {
        # generate a temporary files
        my ($fh, $tree_file) = File::Temp::tempfile();

        $obj->file($inputfile);
        $obj->balance_node_depth();

	my $tree = $obj->{_tree};

	print $fh $tree->as_text('newick');

	my $cmd = join(" ", ($qdist_executable, $inputfile, $tree_file));

	my $result = qx($cmd);

	# check if result contains zeros for the distances:
	# data/tree_a.newick : 0 0
	#    /tmp/e3HIyEiRSF : 0 0

	# delete filenames
	$result =~ s/^[^:]+:\s*//mg;
	# delete newlines
	$result =~ s/\n/ /g;
	# delete spaces
	$result =~ s/^\s*|\s*$//g;

	my %qdists = ();

	foreach my $qdist (split(/\s+/, $result))
	{
	     $qdists{$qdist}++;
	}

	ok( (keys %qdists)==1 && exists $qdists{0}, "Tree topology still the same for input tree '$inputfile'");
    }
}

done_testing;

__DATA__
data/tree_a.newick
data/tree_b.newick
data/tree_c.newick