#!/usr/bin/perl

use strict;
use warnings;
use Test::More 'no_plan';
use File::Temp 'tempdir';
use Linux::Inotify;

sub test1 () {
   my $dir = tempdir(CLEANUP => 1);
   my $notifier = Linux::Inotify->new();
   my $watch = $notifier->add_watch($dir, Linux::Inotify::ALL_EVENTS);
   open TEST, ">$dir/test";
   my @events = $notifier->read();
   close TEST;
   return $events[0]->fullname() eq "$dir/test" and
          $events[0]->{mask} == Linux::Inotify::CREATE and
	  $events[0]->{cookie} == 0;
}

sub test2 () {
   my $dir = tempdir(CLEANUP => 1);
   my $notifier = Linux::Inotify->new();
   my $watch = $notifier->add_watch($dir, Linux::Inotify::ALL_EVENTS);
   open TEST, ">$dir/test";
   my @events = $notifier->read();
   close TEST;
   @events = $notifier->read();
   return $events[0]->fullname() eq "$dir/test" and
          $events[0]->{mask} == Linux::Inotify::CLOSE and
	  $events[0]->{cookie} == 0;
}

ok(test1, 'test1');
ok(test2, 'test2');

