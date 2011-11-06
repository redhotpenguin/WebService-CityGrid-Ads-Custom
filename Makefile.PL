use 5.014001;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'WebService-CityGrid-Ads-Custom',
    VERSION_FROM      => 'lib/WebService/CityGrid/Ads/Custom.pm', # finds $VERSION
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/WebService/CityGrid/Ads/Custom.pm', # retrieve abstract from module
       AUTHOR         => 'Fred Moyer <phred@redhotpenguin.com>') : ()),
);
