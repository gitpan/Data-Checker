######################################################################
# Makefile.PL for Data::Checker
######################################################################

use strict;
use warnings;
use 5.008;
use ExtUtils::MakeMaker 6.30;

my %module_prereq = (
   'Module::Loaded'           => '0',
   'Net::DNS'                 => '0',
   'Net::Ping'                => '0',
   'Net::Ping::External'      => '0',
   'NetAddr::IP'              => '4.073',
   'NetAddr::IP::Lite'        => '0',
   'Parallel::ForkManager'    => '0',
);

my %script_prereq = (
);

my %test_prereq = (
   'Test::Inter'              => '0',
   'Test::More'               => '0',
);

my %config_prereq = (
   'ExtUtils::MakeMaker'      => '6.30',
);

%module_prereq = (%module_prereq,%script_prereq);
my $EU_MM_V    = $ExtUtils::MakeMaker::VERSION;
$EU_MM_V       =~ s/_//g;
if ($EU_MM_V < 6.64) {
   %config_prereq = (%config_prereq,%test_prereq);
}

WriteMakefile(
   NAME             => "Data::Checker",
   VERSION          => "1.05",
   ABSTRACT         => "a framework for checking data validity",
   LICENSE          => "perl",
   ($EU_MM_V >= 6.48
    ? (MIN_PERL_VERSION => "5.008")
    : ()),
   AUTHOR           => "Sullivan Beck (sbeck\@cpan.org)",
   "dist"           => {COMPRESS=>"gzip",SUFFIX=>"gz"},
   PL_FILES         => {},
   PREREQ_PM        => \%module_prereq,
   ($EU_MM_V >= 6.52
    ? (CONFIGURE_REQUIRES => \%config_prereq)
    : ()),
   ($EU_MM_V >= 6.64
    ? (TEST_REQUIRES   => \%test_prereq)
    : ()),

   ($EU_MM_V > 6.45
    ? (META_MERGE => {
        resources => {
           repository => {
              type => "git",
              web  => "https://github.com/SBECK-github/Data-Checker",
              url  => "git://github.com/SBECK-github/Data-Checker.git",
           }
        }
       })
    : ()),
);
