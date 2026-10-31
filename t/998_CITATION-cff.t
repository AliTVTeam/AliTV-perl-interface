use strict;
use warnings;

use Test::More;
use YAML;

my $citation_file = 'CITATION.cff';

ok(-e $citation_file, 'The file CITATION.cff exists');

my $cff;
eval { $cff = YAML::LoadFile($citation_file); };
ok(!$@ && ref($cff) eq 'HASH', 'CITATION.cff is a valid YAML file');

# required keys of the Citation File Format 1.2.0
foreach my $key (qw(cff-version message authors title))
{
    ok(exists $cff->{$key}, "CITATION.cff contains the required key '$key'");
}

is($cff->{'cff-version'}, '1.2.0', 'CITATION.cff uses cff-version 1.2.0');
is($cff->{'title'}, 'AliTV-perl-interface', 'The title is AliTV-perl-interface');
is($cff->{'doi'}, '10.5281/zenodo.597916', 'The DOI is the Zenodo concept DOI of all versions');

# the version needs to match the newest entry in the Changes file
open(my $fh, '<', 'Changes') || die "Unable to open Changes: $!";
my $changes_version;
while (<$fh>)
{
    if (/^(\d+\.\d+\.\d+)\s/)
    {
	$changes_version = $1;
	last;
    }
}
close($fh) || die "Unable to close Changes: $!";

ok(defined $changes_version, 'Found a version in the Changes file');
is($cff->{'version'}, $changes_version, 'The version in CITATION.cff matches the newest version in Changes');

done_testing;
