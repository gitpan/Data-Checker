#!/usr/bin/perl -w

use Test::Inter;
$t = new Test::Inter 'DNS tests';
$testdir = '';
$testdir = $t->testdir();

use Data::Checker;
$obj   = new Data::Checker;

sub test {
   my($data,$opts) = @_;
   my($pass,$fail,$info,$warn) = $obj->check($data,"DNS",$opts);
   my @out = ("PASS");
   if (ref($pass) eq 'ARRAY') {
      push(@out,sort @$pass);
   } else {
      push(@out,sort keys %$pass);
   }

   push(@out,"FAIL");
   foreach my $ele (sort keys %$fail) {
      push(@out,join(' ',$ele,@{ $$fail{$ele} }));
   }

   push(@out,"INFO");
   foreach my $ele (sort keys %$info) {
      push(@out,join(' ',$ele,@{ $$info{$ele} }));
   }

   push(@out,"WARN");
   foreach my $ele (sort keys %$warn) {
      push(@out,join(' ',$ele,@{ $$warn{$ele} }));
   }

   return @out;
}

$tests=q(

[ foo bar foo.com bar.com ] { qualified __undef__ }
   =>
   PASS
   bar.com
   foo.com
   FAIL
   'bar Host is not fully qualified'
   'foo Host is not fully qualified'
   INFO
   WARN

[ foo bar foo.com bar.com ] { qualified { negate 1 } }
   =>
   PASS
   bar
   foo
   FAIL
   'bar.com Host is fully qualified'
   'foo.com Host is fully qualified'
   INFO
   WARN

[ cpan.org aaa.bbb.ccc ]
   =>
   PASS
   cpan.org
   FAIL
   'aaa.bbb.ccc Host is not defined in DNS'
   INFO
   WARN

[ cpan.org aaa.bbb.ccc ] { dns __undef__ }
   =>
   PASS
   cpan.org
   FAIL
   'aaa.bbb.ccc Host is not defined in DNS'
   INFO
   WARN

[ cpan.org aaa.bbb.ccc ] { dns { negate 1 } }
   =>
   PASS
   aaa.bbb.ccc
   FAIL
   'cpan.org Host is already in DNS'
   INFO
   WARN

{ cpansearch.perl.org { ip [ 199.15.176.161 ] } www.pm.org { ip [ 1.2.3.4 ] } }
{ dns __undef__ expected_ip __undef__ }
   =>
   PASS
   cpansearch.perl.org
   FAIL
   'www.pm.org DNS ip value does not match expected value'
   INFO
   WARN

[ cpansearch.perl.org blogs.perl.org www.pm.org ]
{ dns __undef__ expected_domain { value perl.org } }
   =>
   PASS
   blogs.perl.org
   cpansearch.perl.org
   FAIL
   'www.pm.org DNS domain value does not match expected value'
   INFO
   WARN

{ cpansearch.perl.org { domain perl.org } blogs.perl.org { domain [ perl.org perl.com ] } www.pm.org { domain perl.org } }
{ dns __undef__ expected_domain __undef__ }
   =>
   PASS
   blogs.perl.org
   cpansearch.perl.org
   FAIL
   'www.pm.org DNS domain value does not match expected value'
   INFO
   WARN

);

$t->tests(func  => \&test,
          tests => $tests);
$t->done_testing();

#Local Variables:
#mode: cperl
#indent-tabs-mode: nil
#cperl-indent-level: 3
#cperl-continued-statement-offset: 2
#cperl-continued-brace-offset: 0
#cperl-brace-offset: 0
#cperl-brace-imaginary-offset: 0
#cperl-label-offset: 0
#End:
