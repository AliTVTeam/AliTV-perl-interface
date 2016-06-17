#!/usr/bin/env perl

use strict;
use warnings;

use AliTV;

my $yml = "";

if (@ARGV == 1)
{
    $yml = shift @ARGV;
}

my $obj = AliTV->new(-file => $yml);

my $output = $obj->run();

print $output;

=pod

=encoding utf8

=head1 NAME

alitv.pl - generate the required JSON files for AliTV

=head1 SYNOPSIS

alitv.pl options.yml

=head1 DESCRIPTION

The script creates the required JSON files to run AliTV. The two
output files are required to load into the AliTV website to use AliTV
for the visualization of multiple whole genome alignments.

=head1 AUTHOR

Frank FE<246>rster E<lt>foersterfrank@gmx.deE<gt>

=head1 SEE ALSO

=over 4

=item *
L<AliTV-Demo-Page|http://bioinf-wuerzburg.github.io/AliTV/d3/AliTV.html>

=item *
L<AliTV-Website|http://bioinf-wuerzburg.github.io/AliTV/>

=item *
L<AliTV-Github-Page|https://github.com/BioInf-Wuerzburg/AliTV>


=back

=cut

__DATA__

---
# this is the default yml file
output:
    data: data.json
    conf: conf.json
    filter: filter.json
alignment:
    program: lastz
    parameter:
       - "--format=maf"
       - "--noytrim"
       - "--ambiguous=iupac"
       - "--gapped"

