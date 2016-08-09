use strict;
use warnings;

use Test::More;
use Test::Exception;

use Digest::MD5;

BEGIN { use_ok('AliTV') };

# this test is not required as it always has a file method
can_ok('AliTV', qw(_write_mapping_file));

my $obj = new_ok('AliTV');

throws_ok { $obj->_write_mapping_file(); } qr/Need to call _write_mapping_file\(\) with an array reference as parameter/, 'Exception if called without a parameter';

throws_ok { $obj->_write_mapping_file(1); } qr/Need to call _write_mapping_file\(\) with an array reference as parameter but found other type/, 'Exception if called without a array reference as parameter';

$obj->project("Test");

my $seqs = [
   {
      genome => "A",
      name => "A_name",
      uniq_name => "A_name_uniq"
   },
   {
      genome => "B",
      name => "B_name",
      uniq_name => "B_name_uniq"
   }
];

$obj->_write_mapping_file($seqs);

my $expected_file = "Test.map";

ok(-e $expected_file, 'Mapping file was created as expected');

open(my $fh, "<", $expected_file) || die "Unable to open expected outputfile '$expected_file': $!\n";
my $ctx = Digest::MD5->new;
$ctx->addfile($fh);

is($ctx->hexdigest, 'fef31e891cf5cf969ca15e98a9295a4a', 'Expected mapping file content was created');

close($fh) || die "Unable to close expected outputfile '$expected_file': $!\n";

unlink($expected_file) || die "Unable to delete file '$expected_file'\n";

done_testing;