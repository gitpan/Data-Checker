package Data::Checker::DNS;
# Copyright (c) 2013-2014 Sullivan Beck. All rights reserved.
# This program is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.

###############################################################################

require 5.008;
use warnings 'all';
use strict;
use Net::DNS;

our($VERSION);
$VERSION = '1.00';

###############################################################################
###############################################################################

sub check {
   my($obj,$element,$desc,$check_opts) = @_;
   my $err  = [];
   my $warn = [];
   my $info = [];

   if (! defined $check_opts) {
      $check_opts = { 'dns' => undef };
   }

   # Do the qualified check

   my @host = split(/\./,$element);
   my($fqhost,$uqhost,$domain);
   if (@host == 1) {
      $uqhost = $element;
   } else {
      $fqhost = $element;
      $uqhost = shift(@host);
      $domain = join('.',@host);
   }

   $obj->check_value($check_opts,'qualified',$element,$fqhost,
                     'Host is not fully qualified',
                     'Host is fully qualified',
                     $err,$warn,$info);
   return ($element,$err,$warn,$info)  if (@$err);

   # Set up the resolver

   my $res;
   my $nameservers = $obj->check_option($check_opts,'nameservers');
   if ($nameservers) {
      my @nameservers = split(/\s+/,$nameservers);
      $res = Net::DNS::Resolver->new(nameservers => [@nameservers]);
   } else {
      $res = Net::DNS::Resolver->new();
   }

   # Do the dns check

   my $q      = $res->search($element);
   my $in_dns = ($q ? 1 : 0);

   $obj->check_value($check_opts,'dns',$element,$in_dns,
                     'Host is not defined in DNS',
                     'Host is already in DNS',
                     $err,$warn,$info);
   return ($element,$err,$warn,$info)  if (@$err);

   # Do the expected_* checks

   foreach my $check ('ip','domain','hostname') {
      my $label = "expected_$check";
      next  if (! $obj->check_performed($check_opts,$label));

      # Get the expected value(s)

      my $vals;
      if (defined($desc)  &&
          ref($desc) eq 'HASH'  &&
          exists $$desc{$check}) {
         $vals = $$desc{$check};
      } else {
         $vals = $obj->check_option($check_opts,'value',undef,$label);
      }

      my %vals = ();
      if (defined($vals)) {
         if (ref($vals) eq 'ARRAY') {
            %vals = map { $_,1 } @$vals;
         } elsif (! ref($vals)) {
            %vals = ( $vals => 1 );
         }
      }

      my @vals = keys %vals;
      if (! @vals) {
         die "ERROR: No value provided for expected_$check DNS check.\n";
      }

      # Test each value in DNS

      my @a  = $q->answer();
      foreach my $rr (@a) {
         next  if ($rr->type ne 'A');

         my $value;
         if ($check eq 'ip') {
            $value = $rr->address;
         } elsif ($check eq 'domain') {
            $value = $rr->name;
            $value =~ s/^.*?\.//;
         } else {
            $value = $rr->name;
         }

         $obj->check_value($check_opts,$label,$element,exists $vals{$value},
                           "DNS $check value does not match expected value",
                           "DNS $check value is a restricted value",
                           $err,$warn,$info);
         return ($element,$err,$warn,$info)  if (@$err);
      }
   }

   return ($element,$err,$warn,$info);
}


1;
# Local Variables:
# mode: cperl
# indent-tabs-mode: nil
# cperl-indent-level: 3
# cperl-continued-statement-offset: 2
# cperl-continued-brace-offset: 0
# cperl-brace-offset: 0
# cperl-brace-imaginary-offset: 0
# cperl-label-offset: 0
# End: