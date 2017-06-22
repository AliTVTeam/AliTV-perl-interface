use strict;
use warnings;

use Test::More;
use Digest::MD5;

BEGIN { use_ok('AliTV::Script') };

can_ok('AliTV::Script', qw(run));

my $projectname = "test303";

my @files = glob($projectname."*");
if (@files)
{
    unlink(@files) || die "Unable to remove the files ".$projectname."*\n";
}

my $json_output = $projectname.".json";

AliTV::Script->run("--project", $projectname, qw(data/vectors/M13mp18.fasta  data/vectors/pBluescribeKSPlus.fasta  data/vectors/pBR322.fasta  data/vectors/pUC19.fasta  data/vectors/vectors.fasta));

ok(-e $json_output, 'Expected JSON file exists');
open(my $fh, "<", $json_output) || die "Unable to open file '$json_output'\n";

my $ctx = Digest::MD5->new;
$ctx->addfile($fh);

close($fh) || die "Unable to close file '$json_output'\n";

is($ctx->hexdigest(), "55aa3339f8dfddd17b9467984be47dc9", 'Output JSON contains expected data');

done_testing;

