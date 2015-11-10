use 5.010000;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'AliTV',
    VERSION_FROM      => 'lib/AliTV.pm', # finds $VERSION
    PREREQ_PM         => {
	Test::Exception => 0,
	Storable => 0,              # Core module since perl v5.7.3
	Bio::Root::Version => 1.006923,
	Bio::Seq => 0,              # was 1.006923, but the installed version cannot determined
	Bio::SeqIO => 0,            # was 1.006923, but the installed version cannot determined
    }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/AliTV.pm', # retrieve abstract from module
       AUTHOR         => 'Frank Foerster <frf53jh@>') : ()),
);
