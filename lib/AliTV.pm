package AliTV;

use 5.010000;
use strict;
use warnings;

use parent 'AliTV::Base';

use YAML;
use Hash::Merge;

use AliTV::Genome;
use AliTV::Tree;

use File::Copy;

use JSON;

sub _initialize
{
    my $self = shift;

    # initialize the yml settings using the default config
    $self->{_yml_import} = $self->get_default_settings();
    $self->{_file} = undef;
    $self->{_project} = undef;

    $self->{_genomes} = {};

    $self->{_linkcounter} = 0;
    $self->{_linkfeaturecounter} = 0;

    $self->{_links} = {};

    $self->{_max_total_seq_length_included_into_json} = 1000000;

    $self->{_ticks_every_num_of_bases} = undef;

    $self->{_links_min_len} = 1000000000; # just a huge value
    $self->{_links_max_len} = 0;          # just a tiny value
    $self->{_links_max_id}  = 0;          # just a zero
    $self->{_links_min_id}  = 100;        # just the maximum

    $self->{_tree} = undef;
}

=pod

=head1 Method run

=head2

run the generation script

=cut

sub run
{
    my $self = shift;

    #################################################################
    #
    # Import genomes
    #
    #################################################################
    # Import the given genomes

    $self->_import_genomes();

    #################################################################
    #
    # Create uniq sequence names
    #
    #################################################################
    # if the names are already uniq, the sequences names will be used
    # as unique names, otherwise the sequences will be numbered to
    # generate unique names

    $self->_make_and_set_uniq_seq_names();

    #################################################################
    #
    # Create sequence set
    #
    #################################################################
    # Prepare a sequence set for the alignment

    # determine the module to load from the alignment program
    my $alignment_module = sprintf('AliTV::Alignment::%s', $self->{_yml_import}{alignment}{program});
    unless (eval "require $alignment_module") {
        $self->_logdie("Unable to load alignment module '$alignment_module'");
    }

    my $alignment_parameter = $self->{_yml_import}{alignment}{parameter};

    my $aln_obj = "$alignment_module"->new(-parameters => $alignment_parameter, -callback => sub{ $self->_import_links(@_); } );
    $aln_obj->run($self->_generate_seq_set());
    $aln_obj->export_to_genome();

    #################################################################
    #
    # Import tree
    #
    #################################################################
    if (exists $self->{_yml_import}{tree} && defined $self->{_yml_import}{tree})
    {
	my $tree_obj = AliTV::Tree->new(-file => ($self->{_yml_import}{tree}));
	$tree_obj->ladderize();
	$tree_obj->balance_node_depth();
	$self->{_tree} = $tree_obj->tree_2_json_structure();

	# store the order
	$self->{_tree_genome_order} = $tree_obj->get_genome_order();
    }

    my $json_text = $self->get_json();

    return $json_text;
}

sub get_json
{
    my $self = shift;

    my %data = ();

    $data{data}{links} = $self->{_links};

    my $features = {};
    my $chromosomes = {};

    # cycle though all genomes end extract feature and chromosome information
    foreach my $genome ( values %{$self->{_genomes}} )
    {
	$features = $genome->get_features($features);
	$chromosomes = $genome->get_chromosomes($chromosomes);
    }

    # collect the sequence length of all chromosomes
    my @chromosome_length = sort { $a <=> $b } map {$chromosomes->{$_}{length}} (keys %{$chromosomes});
    # calculate the complete sequence length
    my $complete_seq_length = 0;
    foreach (@chromosome_length) { $complete_seq_length += $_; }

    # if the sequence length is longer than (default) 1 Mb, skip all sequence information from the JSON file
    if ($complete_seq_length > $self->maximum_seq_length_in_json())
    {
	$self->_info(sprintf("Number of bases (%d) is longer than the maximum allowed (%d), therefore sequences will be excluded from JSON file", $complete_seq_length, $self->maximum_seq_length_in_json()));
	foreach (keys %{$chromosomes})
	{
	    $chromosomes->{$_}{seq} = "";
	}
    }

    my $tick_distance = $self->_calculate_tick_distance(\@chromosome_length);
    $self->ticks_every_num_of_bases($tick_distance);
    $self->_info(sprintf("Ticks will be drawn every %d basepair", $self->ticks_every_num_of_bases()));

    $data{data}{features} = $features;
    $data{data}{karyo}{chromosomes} = $chromosomes;

    $data{data}{tree} = $self->{_tree};

    $data{conf} = {
	'circular' => {
	    'tickSize' => 5
	},

        'features' => {
		    'fallbackStyle' => {
			'color' => '#787878',
			'form' => 'rect',
			'height' => 30,
			'visible' => JSON::false
		    },
		    'showAllFeatures' => JSON::false,
		    'supportedFeatures' => { },
	 },

	 'graphicalParameters' => {
	                                'buttonWidth' => 90,
					'canvasHeight' => 900,
					'canvasWidth' => 900,
					'fade' => 0.1,
					'genomeLabelWidth' => 200,
					'karyoDistance' => 5000,
					'karyoHeight' => 30,
					'linkKaryoDistance' => 20,
					'tickDistance' => $self->ticks_every_num_of_bases(),
					'tickLabelFrequency' => 10,
					'treeWidth' => 200
          },
          'labels' => {
	      'chromosome' => {
		  'showChromosomeLabels' => JSON::false
	      },
	      'features' => {
		  'showFeatureLabels' => JSON::false
	      },
	      'genome' => {
		  'color' => '#000000',
		  'showGenomeLabels' => JSON::true,
		  'size' => 25
	      },
	      'showAllLabels' => JSON::false,
	      'ticks' => {
		  'color' => '#000000',
		  'showTickLabels' => JSON::true,
		  'showTicks' => JSON::true,
		  'size' => 10
	       }
            },
	'layout' => 'linear',
	'linear' => {
	    'drawAllLinks' => JSON::false,
	    'endLineColor' => '#1d91c0',
	    'hideHalfVisibleLinks' => JSON::false,
	    'startLineColor' => '#1d91c0'
	},

	'maxLinkIdentity' => 100,
	'maxLinkIdentityColor' => '#1DAD0A',
	'maxLinkLength' => 5000,
	'midLinkIdentity' => 85,
        'midLinkIdentityColor' => '#FFEE05',
        'minLinkIdentity' => 70,
        'minLinkIdentityColor' => '#D21414',
        'minLinkLength' => 100,

	'offset' => {
	    'distance' => 1000,
	    'isSet' => JSON::false
         },

	'tree' => {
	    'drawTree' => JSON::true,
	    'orientation' => 'left'
	}
    };

    # add all features but links
    foreach my $feat (grep {$_ ne $self->_link_feature_name()} (keys %{$data{data}{features}}))
    {
	if (exists $self->{_yml_import}{features}{$feat})
	{
	    $data{conf}{features}{supportedFeatures}{$feat}{color} = $self->{_yml_import}{features}{$feat}{color};
	    $data{conf}{features}{supportedFeatures}{$feat}{form} = $self->{_yml_import}{features}{$feat}{form};
	    $data{conf}{features}{supportedFeatures}{$feat}{height} = $self->{_yml_import}{features}{$feat}{height};
	    $data{conf}{features}{supportedFeatures}{$feat}{visible} = ($self->{_yml_import}{features}{$feat}{visible}) ? JSON::true : JSON::false;
	} else {
	    $data{conf}{features}{supportedFeatures}{$feat} = {
		color => '#EBCE20',
		form => 'rect',
		height => 30,
		visible => JSON::true
	    }
	}
    }

    $data{filters} = {
                         'features' => {
                                         'invisibleFeatures' => {}
                                       },
                         'karyo' => {
                                      'chromosomes' => {},
                                      'genome_order' => [],
                                      'order' => []
                                    },
                         'links' => {
                                      'invisibleLinks' => {},
                                      'maxLinkIdentity' => $self->{_links_max_id}+0,
                                      'maxLinkLength' => $self->{_links_max_len}+0,
                                      'minLinkIdentity' => $self->{_links_min_id}+0,
                                      'minLinkLength' => $self->{_links_min_len}+0
                                    },
                         'onlyShowAdjacentLinks' => JSON::true,
                         'showAllChromosomes' => JSON::false,
                         'showIntraGenomeLinks' => JSON::false,
                         'skipChromosomesWithoutLinks' => JSON::false,
                         'skipChromosomesWithoutVisibleLinks' => JSON::false
    };

    # adding information about the chromosomes
    # first sort the chromosomes
    my @chromosomelist_sorted = sort {
	$data{data}{karyo}{chromosomes}{$a}{genome_id} cmp $data{data}{karyo}{chromosomes}{$b}{genome_id}
	||
	$data{data}{karyo}{chromosomes}{$a}{length} <=> $data{data}{karyo}{chromosomes}{$b}{length}
    } keys %{$data{data}{karyo}{chromosomes}};

    # set each chromosome to visible
    foreach my $chromosome (@chromosomelist_sorted)
    {
	$data{filters}{karyo}{chromosomes}{$chromosome} = {
	    visible => JSON::true,
	    reverse => JSON::false
	};
    }

    $data{filters}{karyo}{order} = \@chromosomelist_sorted;

    # need to define a genome order
    # easy to implement: alphabetically sorted or if a tree exists use the order from the tree
    if (exists $self->{_tree_genome_order})
    {
	# ordered by the tree
	$data{filters}{karyo}{genome_order} = $self->{_tree_genome_order};
    } else {
	# alphabetically sorted
	my %genomes = map { $data{data}{karyo}{chromosomes}{$_}{genome_id} => 1 } (keys %{$data{data}{karyo}{chromosomes}});
	$data{filters}{karyo}{genome_order} = [sort keys %genomes];
    }
    return to_json(\%data);
}

sub _import_links
{
    my $self = shift;

    my ($entry) = @_;

    my @linkdat = ();

    # find the correct sequence
    foreach my $seq ( @{$entry->{seqs}} )
    {
	my $seqname = $seq->{id};
	my $corr_genome = undef;

	foreach my $curr_genome ( values %{$self->{_genomes}} )
	{
	    if ($curr_genome->seq_exists($seqname)) #exists $self->{_genomes}{$genome}{_seq}{$seqname})
	    {
		# genome with sequence with correct name was found
		# add the feature
		my $linkfeature_name = sprintf("linkfeature%06d", ++$self->{_linkfeaturecounter});
		my $returned_linkfeature_name = $curr_genome->_store_feature($self->_link_feature_name(), $seqname, $seq->{start}+0, $seq->{end}+0, $seq->{strand}, $linkfeature_name);
		push(@linkdat, {genome => $curr_genome->name(), feature => $returned_linkfeature_name});

		last;
	    }
	}
    }

    # add a new link to the link-list
    $self->_logdie("unable to create features") unless (@linkdat == 2);
    $self->{_linkcounter}++;
    my $genome1 = $linkdat[0]{genome};
    my $genome2 = $linkdat[1]{genome};

    # sort the genomes alphabetically
    if ($genome2 lt $genome1)
    {
	($genome1, $genome2) = ($genome2, $genome1);
    }

    my $linkname = sprintf("link%06d", $self->{_linkcounter});
    my $dataset = { source => $linkdat[0]{feature}, identity => sprintf("%.2f", $entry->{identity})+0, target => $linkdat[1]{feature} };
    # check if an existing link exists
    my $link_already_existing = 0;
    # search the links
    foreach my $existing_linkname (keys %{$self->{_links}{$genome1}{$genome2}})
    {
	my $existing_dataset = $self->{_links}{$genome1}{$genome2}{$existing_linkname};
	if (
	    $existing_dataset->{source} eq $dataset->{source}
	    &&
	    $existing_dataset->{identity} eq $dataset->{identity}
	    &&
	    $existing_dataset->{target} eq $dataset->{target}
	    )
	{
	    $self->_debug("Existing link will be skipped");
	    $link_already_existing++;
	}

    }

    # add the new link if not already existing
    unless ($link_already_existing)
    {
	$self->{_links}{$genome1}{$genome2}{$linkname} = $dataset;
    }

    # track minimum and maximum link length and identity
    if ($self->{_links_min_len} > $entry->{len})
    {
	$self->{_links_min_len} = $entry->{len}+0;
    }
    if ($self->{_links_max_len} < $entry->{len})
    {
	$self->{_links_max_len} = $entry->{len}+0;
    }

    if ($self->{_links_min_id} > $entry->{identity})
    {
	$self->{_links_min_id} = $entry->{identity}+0;
    }
    if ($self->{_links_max_id} < $entry->{identity})
    {
	$self->{_links_max_id} = $entry->{identity}+0;
    }
}

=pod

=head2 Method $alitv_obj->project()

This methods returns the name of the current project. If an additional
parameter is given, this value will be set as new project name. Those
names are allowed to contain only characters from [A-Za-z0-9_]. In
case they contain other characters, an exception will be raised.

=cut

sub project
{
    my $self = shift;

    # is another parameter given?
    if (@_)
    {
	$self->{_project} = shift;

	if ($self->{_project} =~ /[^A-Za-z0-9_]/)
	{
	    $self->_logdie('Only characters from character class [A-Za-z0-9_] are allowed in project name');
	}
    }

    return $self->{_project};
}

sub file
{
    my $self = shift;

    # is another parameter given?
    if (@_)
    {
	$self->{_file} = shift;

	my $default = $self->get_default_settings();

	# try to import the YAML file
	my $settings;
	eval { $settings = YAML::LoadFile($self->{_file}) };
	if ($@)
	{
	    $self->_logdie("Unable to import the YAML file '".$self->{_file}."': $@");
	}

	Hash::Merge::set_behavior( 'RIGHT_PRECEDENT' );

	if (exists $settings->{alignment})
	{
	    delete $default->{alignment};
	}

	$self->{_yml_import} = Hash::Merge::merge($default, $settings);
    }

    return $self->{_file};
}

sub _import_genomes
{

    my $self = shift;

    # check if a file attribute is set and not undef
    unless (exists $self->{_file} && defined $self->{_file})
    {
	$self->_logdie("No file attribute exists");
    }

    foreach my $curr_genome (@{$self->{_yml_import}{genomes}})
    {
	my $genome = AliTV::Genome->new(%{$curr_genome});
	# check that the genome name is not already existing

	if (exists $self->{_genomes}{$genome->name()})
	{
	    $self->_logdie(sprintf("Genome-ID '%s' is not uniq", $genome->name()));
	}

	$self->{_genomes}{$genome->name()} = $genome;
    }
}

sub get_default_settings
{
    my $default_yml_content = '
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
       - "--strand=both"
';

    # try to import the default YAML
    my $default = YAML::Load($default_yml_content);

    return $default;
}

sub _make_and_set_uniq_seq_names
{
    my $self = shift;

    # get a list of all sequence names

    my @all_seq_ids = ();

    foreach my $genome_id (sort keys %{$self->{_genomes}})
    {
	push(@all_seq_ids, map { {name => $_, genome => $genome_id} } (sort $self->{_genomes}{$genome_id}->get_seq_names()));
    }

    # check if the sequence names are uniq
    my %seen = ();

    foreach my $curr (@all_seq_ids)
    {
	$seen{$curr->{name}}++;
    }

    # if the number of keys is equal to the number of total sequences,
    # they should be uniq, but we need to guarantee, that the name
    # contains only alphanumeric or "word" characters and that the
    # name is not longer than $max_seq_length characters
    my $max_seq_length = 8;
    my $uniq_names = ((keys %seen) == @all_seq_ids);
    my $only_word_characters = ((grep {$_->{name} =~ /\W/} @all_seq_ids) == 0);
    my $comply_maximum_id_length = ((grep {length($_->{name}) > $max_seq_length} @all_seq_ids) == 0);

    if ( $uniq_names && $only_word_characters && $comply_maximum_id_length)
    {
	# sequence names are uniq and can be used as uniq names
	@all_seq_ids = map { {name => $_->{name}, genome => $_->{genome}, uniq_name => $_->{name}} } (@all_seq_ids);
    } elsif (! $uniq_names) {
	$self->_info("Sequence names are not unique and will be replaced by unique sequence names\n");
    } elsif (! $only_word_characters) {
	$self->_info(
	    sprintf("Sequence names contain non-word-characters and will be replaced by unique sequence names. Failing sequence names are: %s\n",
		    join(", ",
			 map {"'$_->{name}'"}
			   grep {$_->{name} =~ /\W/} @all_seq_ids
		    )
	    )
	);
    } elsif (! $comply_maximum_id_length) {
	$self->_info(
	    sprintf("Sequence names are longer then maximum allowed length (%d characters) and will be replaced by unique sequence names. Failing sequence names are: %s\n",
		    $max_seq_length,
		    join(", ",
			 map {"'$_->{name}'"}
			   grep {length($_->{name}) > $max_seq_length} @all_seq_ids
		    )
	    )
	    );
    } else {
	$self->_logdie("Should never be reached"); # uncoverable statement
    }

    # sequences names are not uniq! Therefore, generate new names
    unless ( $uniq_names && $only_word_characters && $comply_maximum_id_length)
    {
	my $counter = 0;

	@all_seq_ids = map { {name => $_->{name}, genome => $_->{genome}, uniq_name => "seq".$counter++ } } (@all_seq_ids);
    }

    # set the new uniq names for each genome
    foreach my $genome_id (keys %{$self->{_genomes}})
    {
	my @set_list = map { $_->{uniq_name} => $_->{name} } grep {$_->{genome} eq $genome_id } @all_seq_ids;

	$self->{_genomes}{$genome_id}->set_uniq_seq_names(@set_list);
    }

    $self->_write_mapping_file(\@all_seq_ids);
}

=pod

=head2 Method $alitv_obj->_write_mapping_file()

This internal method stores a file containing old and new sequence
names for the complete sequence set. If the file already exists, it
will be backed up. If this is not possible an exception will be
raised.

=cut

sub _write_mapping_file
{
    my $self = shift;

    unless (@_)
    {
	$self->_logdie("Need to call _write_mapping_file() with an array reference as parameter");
    }
    my $ref_to_seqs = shift;
    unless (ref($ref_to_seqs) eq "ARRAY")
    {
	$self->_logdie("Need to call _write_mapping_file() with an array reference as parameter but found other type");
    }

    if ($self->project())
    {
	my $outputfilename = $self->project().".map";
	if (-e $outputfilename)
	{
	    $self->_logwarn("The file '$outputfilename' exists. Therefore, a backup will be created named '$outputfilename".'.bak'."' and the old file will overwritten.");

	    if (-e $outputfilename.".bak")
	    {
		$self->_logdie("Unable to backup the file '$outputfilename' to '$outputfilename".".bak' due to it already exists!");
	    }
	    copy($outputfilename, $outputfilename.".bak") || $self->_logdie("Unable to backup the file '$outputfilename' to '$outputfilename".".bak': $!");
	}

	open(FH, ">", $outputfilename) || $self->_logdie("Unable to open file '$outputfilename' for writing: $!");
	print FH "#", join("\t", qw(genome old_name new_name)), "\n";
	foreach my $seq (@{$ref_to_seqs})
	{
	    print FH join("\t", ($seq->{genome}, $seq->{name}, $seq->{uniq_name})), "\n";
	}
	close(FH) || $self->_logdie("Unable to open file '$outputfilename' for writing: $!");
    }
}

sub _generate_seq_set
{
    my $self = shift;

    my @seqs = ();

    # generate a list od all sequences
    foreach my $genome_id (keys %{$self->{_genomes}})
    {
	my @new_seqs = $self->{_genomes}{$genome_id}->get_sequences();

	push(@seqs, @new_seqs);
    }

    # finally, sort the sequences by id and sequence
    @seqs = sort {$a->id() cmp $b->id() || $a->seq() cmp $b->seq()} (@seqs);
    
    # store the sequence set as attribute
    $self->{_seq_set} = \@seqs;

    # and return it
    return $self->{_seq_set};
}

=pod

=head3 C<$obj-E<gt>maximum_seq_length_in_json()>

=head4 I<Parameters>

If one single integer value is provided, it will be used as threshold
for the maximal sequence length inside the produced JSON file.

=head4 I<Output>

Returns the current value of the maximal sequence length inside the
produced JSON file.

=head4 I<Description>

none

=cut

sub maximum_seq_length_in_json
{
    my $self = shift;

    if (@_)
    {
	my $parameter = shift;
	unless ($parameter =~ /^\d+$/)
	{
	    $self->_logdie("Parameter needs to be an unsigned integer value");
	}
	$self->{_max_total_seq_length_included_into_json} = $parameter;
    }
    return $self->{_max_total_seq_length_included_into_json};
}

=pod

=head3 C<$obj-E<gt>ticks_every_num_of_bases()>

=head4 I<Parameters>

If one single integer value is provided, it will be determine how many
ticks are drawn.

=head4 I<Output>

Returns the current value of the class value.

=head4 I<Description>

none

=cut

sub ticks_every_num_of_bases
{
    my $self = shift;

    if (@_)
    {
	my $parameter = shift;
	unless ($parameter =~ /^\d+$/)
	{
	    $self->_logdie("Parameter needs to be an unsigned integer value");
	}
	$self->{_ticks_every_num_of_bases} = $parameter;
    }
    return defined $self->{_ticks_every_num_of_bases} ? int($self->{_ticks_every_num_of_bases}) : undef;

}

=pod

=head3 C<$obj-E<gt>_calculate_tick_distance()>

=head4 I<Parameters>

Requires a reference to a list of sequence length.

=head4 I<Output>

Returns the calculated value

=head4 I<Description>

The value for tick distance is calculated as follows: We want to
achieve at least 20 ticks in the sequence with the median length. The
number of bases should be a power of ten.

=cut

sub _calculate_tick_distance
{
    my $self = shift;

    unless (@_ == 1 && ref($_[0]) eq "ARRAY")
    {
	$self->_logdie("Need to provide a reference to an array of integers as parameter");
    }

    my $list = shift;

    @{$list} = sort {$a <=> $b} @{$list};

    # calculate the length of the longest chromosome
    my $longest_chromosome_length = $list->[@{$list}-1];

    # inside the median chromosome, we want to have at least 20 Ticks, but we want to have a power of 10
    my $ticks_every_num_of_bases = int(log($longest_chromosome_length/20)/log(10));
    $ticks_every_num_of_bases = 10**$ticks_every_num_of_bases;

    return $ticks_every_num_of_bases;
}

1;

=pod

=head1 NAME

AliTV - Perl class for the alitv script which generates the JSON input for AliTV

=head1 SYNOPSIS

  use AliTV;

=head1 DESCRIPTION

The class AliTV implements the functionality for the alitv.pl script.

=head1 SEE ALSO

=head1 AUTHOR

Frank FE<246>ster E<lt>foersterfrank@gmx.deE<gt>

=head1 COPYRIGHT AND LICENSE

See the F<LICENCE> file for information about the licence.

=cut
