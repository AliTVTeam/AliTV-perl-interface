use Test::More;
eval "use Test::Pod::Coverage 1.00";

plan skip_all => "Test::Pod::Coverage 1.00 required for testing POD coverage"
  if $@;

my @modules_expect_to_pass = qw(AliTV::Base::Version);
my @modules_expect_to_fail = qw(AliTV::Base AliTV::Seq AliTV::Genome AliTV::Tree AliTV);

foreach my $module (@modules_expect_to_pass) {
    pod_coverage_ok( $module,
        "'$module' is expected to pass POD coverage test" );
}

TODO: {

    local $TODO = "Still missing the documentation";

    foreach my $module (@modules_expect_to_fail) {
        pod_coverage_ok( $module,
            "'$module' is expected to fail POD coverage test" );
    }

}

done_testing();
