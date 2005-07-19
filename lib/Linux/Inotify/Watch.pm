package Linux::Inotify::Watch;

use strict;
use warnings;
use Carp;
require 'syscall.ph';

push our @CARP_NOT, 'Linux::Inotify';

my %all_watches;

sub new($$$$) {
   my $class = shift;
   my %self = (
      fd    => shift,
      name  => shift,
      mask  => shift,
      valid => 1
   );
   $self{wd} = syscall 292, $self{fd}->{fd}, $self{name}, $self{mask};
   croak "Linux::Inotify::Watch::new() failed: $!" if $self{wd} == -1;
   bless \%self, $class;
   $all_watches{$self{wd}} = \%self;
   return \%self;
}

sub clone($$) {
   my $source = shift;
   my %target = (
      fd    => $source->{fd},
      name  => shift,
      mask  => $source->{mask},
      valid => 1
   );
   $target{wd} = syscall 292, $target{fd}->{fd}, $target{name}, $target{mask};
   croak "Linux::Inotify::Watch::new() failed: $!" if $target{wd} == -1;
   bless \%target, ref($source);
   $all_watches{$target{wd}} = \%target;
   return \%target;
}

sub find($$) {
   my $class = shift;
   my $wd = shift;
   return $all_watches{$wd};
}

sub invalidate($) {
   my $self = shift;
   $self->{valid} = 0;
}

sub remove($) {
   my $self = shift;
   if ($self->{valid}) {
      my $ret = syscall 293, $self->{fd}->{fd}, $self->{wd};
      croak "Linux::Inotify::Watch::remove(wd = $self->{wd}) failed: $!" if $ret == -1;
   }
   delete $all_watches{$self->{wd}};
}

1;

