use strict;
use warnings;

use Test::More;
use Test::Exception;
use JSON;
use Digest::MD5 qw(md5_hex);

BEGIN { use_ok('AliTV') };

can_ok('AliTV', qw(maximum_seq_length_in_json));

my $obj = new_ok('AliTV');

my @forbidden_values = (-1, "A", {}, [], 0.5);
foreach my $forbidden_value (@forbidden_values)
{
	throws_ok { $obj->maximum_seq_length_in_json($forbidden_value); } qr/Parameter needs to be an unsigned integer value/, "Exception if parameter is no unsigned integer value (used '$forbidden_value' for test)";
}

lives_ok { $obj->maximum_seq_length_in_json(12345); } 'No exception if parameter is an unsigned integer value';

# recreate our object
$obj = new_ok('AliTV');

my $expected_default = 1000000;
is($obj->maximum_seq_length_in_json(), $expected_default, 'Default value will be returned');

my $new_value = 1234567;
is($obj->maximum_seq_length_in_json($new_value), $new_value, 'New value will be returned while setting the new value');
is($obj->maximum_seq_length_in_json(), $new_value, 'New value will be returned after setting a new value');

my $vectorset = 'data/vectors/input.yml';

my $obj_skipped_seqs = new_ok('AliTV', ["-file" => $vectorset]);
my $seq_skipped_value = 10000;
$obj_skipped_seqs->maximum_seq_length_in_json($seq_skipped_value);
my $without_seqs = decode_json($obj_skipped_seqs->run());

my $obj_incl_seqs = new_ok('AliTV', ["-file" => $vectorset]);
my $seq_incl_value = 100000;
$obj_incl_seqs->maximum_seq_length_in_json($seq_incl_value);
my $with_seqs_set = decode_json($obj_incl_seqs->run());

my $obj_default_seqs = new_ok('AliTV', ["-file" => $vectorset]);
my $with_seqs_default = decode_json($obj_default_seqs->run());

# the m5sums for each input file was determined by
#
# for i in data/vectors/*.fasta; do echo "$i:"$(grep -v "^>" "$i" | tr -d "\n" | md5sum | awk '{print $1}'); done | column -tx -s ":"
# data/vectors/M13mp18.fasta            977004f16cc7cbc9eddeb909d8222592
# data/vectors/pBluescribeKSPlus.fasta  5497d85208eb4e3108dfe3e263951f4f
# data/vectors/pBR322.fasta             06f26532a24bff6f3a6d04d70bfdbff3
# data/vectors/pUC19.fasta              dcaa58eea40748c8ed5417afbd3da5f5

my $md5 = {
   empty             => md5_hex(""),
   M13mp18           => "977004f16cc7cbc9eddeb909d8222592",
   pBluescripeKSPlus => "5497d85208eb4e3108dfe3e263951f4f",
   pBR322            => "06f26532a24bff6f3a6d04d70bfdbff3",
   pUC19             => "dcaa58eea40748c8ed5417afbd3da5f5"
   };

run_test(expected => [$md5->{empty}, $md5->{empty}, $md5->{empty}, $md5->{empty}], test_set_name => "skipped sequences test", json => $without_seqs);
run_test(expected => [$md5->{M13mp18}, $md5->{pBR322}, $md5->{pBluescripeKSPlus},  $md5->{pUC19}], test_set_name => "skipped sequences test", json => $with_seqs_set);
run_test(expected => [$md5->{M13mp18}, $md5->{pBR322}, $md5->{pBluescripeKSPlus}, $md5->{pUC19}], test_set_name => "skipped sequences test", json => $with_seqs_default);

done_testing;

sub run_test
{
  my %params = @_;

  ok(exists $params{json}{data}, 'Key data exists in returned json for '.$params{test_set_name});
  ok(exists $params{json}{data}{karyo}, 'Key karyo exists in returned json for '.$params{test_set_name});
  ok(exists $params{json}{data}{karyo}{chromosomes}, 'Key karyo exists in returned json for '.$params{test_set_name});

  my @got = map {md5_hex($params{json}{data}{karyo}{chromosomes}{$_}{seq})} (sort keys %{$without_seqs->{data}{karyo}{chromosomes}});

  is_deeply(\@got, $params{expected}, "Sequences are as expected for ".$params{test_set_name});

}
