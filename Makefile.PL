use 5.010000;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'AliTV',
    VERSION_FROM      => 'lib/AliTV/Base/Version.pm', # finds $VERSION
    EXE_FILES         => [
	'bin/alitv.pl'
    ],
    PREREQ_PM         => {
	Test::Exception => 0,
	Test::Warnings => 0,
	Storable => 0,              # Core module since perl v5.7.3
	Bio::Root::Version => 0,    # should be 1.006923 but does not seem to work
	Bio::Seq => 0,              # was 1.006923, but the installed version cannot determined
	Bio::SeqIO => 0,            # was 1.006923, but the installed version cannot determined
	Bio::TreeIO => 0,           # was 1.006923, but the installed version cannot determined
	Bio::Tree::TreeI => 0,      # was 1.006923, but the installed version cannot determined
	Bio::Tree::Node => 0,       # was 1.006923, but the installed version cannot determined
	Bio::AlignIO    => 0,       # was 1.006923, but the installed version cannot determined
	JSON            => 0,
	YAML            => 0,
        IPC::System::Simple => 0,
        File::Temp => 0,
        File::Basename => 0,
	File::Copy => 0,
	Log::Log4perl => 0.28,      # required for dynamically determined log file name
        Hash::Merge => 0,
        File::Which => 0,
        File::Path => 0,
	version => 0.77,
	Storable => 0,
        Digest::MD5 => 0,
	FindBin::Real => 0,
    }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/AliTV.pm', # retrieve abstract from module
       AUTHOR         => 'Frank Foerster <frf53jh@>') : ()),
);
