use strict;
use warnings;

use Test::More;
use JSON;
use YAML;

my $zenodo_file = '.zenodo.json';

ok(-e $zenodo_file, 'The file .zenodo.json exists');

my $zenodo;
eval {
    open(my $fh, '<:raw', $zenodo_file) || die "Unable to open $zenodo_file: $!";
    local $/;
    my $content = <$fh>;
    close($fh) || die "Unable to close $zenodo_file: $!";
    $zenodo = JSON->new->utf8->decode($content);
};
ok(!$@ && ref($zenodo) eq 'HASH', '.zenodo.json is a valid JSON file');

is($zenodo->{upload_type}, 'software', 'The upload type is software');
is($zenodo->{license}, 'MIT', 'The license is MIT');
ok(defined $zenodo->{title} && $zenodo->{title} ne '', 'A title is given');
ok(defined $zenodo->{description} && $zenodo->{description} ne '', 'A description is given');

# the creators need to match the authors in CITATION.cff
my $cff = YAML::LoadFile('CITATION.cff');
my @expected_creators = map { $_->{'family-names'}.', '.$_->{'given-names'} } @{$cff->{authors}};
my @creators = map { $_->{name} } @{$zenodo->{creators} || []};
is_deeply(\@creators, \@expected_creators, 'The creators match the authors in CITATION.cff');

my @expected_orcids = map { (my $orcid = $_->{orcid} // '') =~ s|^https://orcid\.org/||; $orcid } @{$cff->{authors}};
my @orcids = map { $_->{orcid} // '' } @{$zenodo->{creators} || []};
is_deeply(\@orcids, \@expected_orcids, 'The ORCIDs match the authors in CITATION.cff');

# the article is linked
my @article = grep { $_->{identifier} eq $cff->{'preferred-citation'}{doi} } @{$zenodo->{related_identifiers} || []};
is(scalar(@article), 1, 'The article from CITATION.cff is a related identifier');

done_testing;
