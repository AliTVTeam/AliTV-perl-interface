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

### Second writing should create another file with suffix .bak

$obj->_write_mapping_file($seqs);

my $expected_bak_file = $expected_file.".bak";

ok(-e $expected_bak_file, 'Backup mapping file was created as expected');

open(my $fh_bak, "<", $expected_bak_file) || die "Unable to open expected backup file '$expected_bak_file': $!\n";
my $ctx_bak = Digest::MD5->new;
$ctx_bak->addfile($fh_bak);

is($ctx_bak->hexdigest, 'fef31e891cf5cf969ca15e98a9295a4a', 'Expected backup mapping file content was created');

close($fh_bak) || die "Unable to close expected outputfile '$expected_file': $!\n";


### Third writing should raise an exception

throws_ok { $obj->_write_mapping_file($seqs); } qr/Unable to backup the file 'Test.map' to 'Test.map.bak' due to it already exists!/, 'Exception is raised if backup file cannot be created';

foreach my $file ($expected_file, $expected_bak_file)
{
   unlink($file) || die "Unable to delete file '$file'\n";
}

done_testing;