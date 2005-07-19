package Linux::Inotify::Event;

use strict;
use warnings;

sub new($$) {
   my $class = shift;
   my $raw_event = shift;
   my %event;
   ($event{wd}, $event{mask}, $event{cookie}, $event{len}) =
      unpack 'iIII', $raw_event;
   $event{name} = unpack 'Z*', substr($raw_event, 16, $event{len});
   bless \%event, $class;
   use Linux::Inotify;
   if ($event{mask} & Linux::Inotify::DELETE_SELF) {
      use Linux::Inotify::Watch;
      my $watch = Linux::Inotify::Watch->find($event{wd});
      $watch->invalidate();
   }
   return \%event;
}

sub fullname($) {
   my $self = shift;
   use Linux::Inotify::Watch;
   my $watch = Linux::Inotify::Watch->find($self->{wd});
   return $watch->{name} . '/' . $self->{name};
}

sub add_watch($) {
   my $self = shift;
   use Linux::Inotify::Watch;
   my $watch = Linux::Inotify::Watch->find($self->{wd});
   return $watch->clone($self->fullname());
}

my %reverse;

INIT {
   %reverse = (
      0x00000001 => 'access',
      0x00000002 => 'modify',
      0x00000004 => 'attrib',
      0x00000008 => 'close_write',
      0x00000010 => 'close_nowrite',
      0x00000020 => 'open',
      0x00000040 => 'moved_from',
      0x00000080 => 'moved_to',
      0x00000100 => 'create',
      0x00000200 => 'delete',
      0x00000400 => 'delete_self',
      0x00002000 => 'unmount',
      0x00004000 => 'q_overflow',
      0x00008000 => 'ignored',
   );
   my %reverse_copy = %reverse;
   while(my ($key, $value) = each %reverse_copy) {
      use Linux::Inotify;
      $reverse{Linux::Inotify::ISDIR | $key} = "isdir | $value";
   }
}

sub print(%) {
   my $self = shift;
   printf "wd: %d, %21s, cookie: 0x%08x, len: %3d, name: '%s'\n",
      $self->{wd}, $reverse{$self->{mask}}, $self->{cookie}, $self->{len},
      $self->fullname();
}

1;

