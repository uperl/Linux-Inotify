package Linux::Inotify::Watch;

use strict;
use warnings;
use Carp;
require 'syscall.ph';

push our @CARP_NOT, 'Linux::Inotify';

sub new($$$$) {
   my $class = shift;
   my $self = {
      notifier => shift,
      name     => shift,
      mask     => shift,
      valid    => 1
   };
   $self->{wd} =
      syscall 292, $self->{notifier}->{fd}, $self->{name}, $self->{mask};
   croak "Linux::Inotify::Watch::new() failed: $!" if $self->{wd} == -1;
   return bless $self, $class;
}

sub clone($$) {
   my $source = shift;
   my $target = {
      notifier => $source->{notifier},
      name     => shift,
      mask     => $source->{mask},
      valid    => 1
   };
   $target->{wd} =
      syscall 292, $target->{notifier}->{fd}, $target->{name}, $target->{mask};
   croak "Linux::Inotify::Watch::new() failed: $!" if $target->{wd} == -1;
   return bless $target, ref($source);
}

sub invalidate($) {
   my $self = shift;
   $self->{valid} = 0;
}

sub remove($) {
   my $self = shift;
   if ($self->{valid}) {
      $self->invalidate;
      my $ret = syscall 293, $self->{notifier}->{fd}, $self->{wd};
      croak "Linux::Inotify::Watch::remove(wd = $self->{wd}) failed: $!" if
	 $ret == -1;
   }
}

1;

