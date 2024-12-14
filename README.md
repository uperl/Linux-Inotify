# Linux::Inotify ![static](https://github.com/uperl/Linux-Inotify/workflows/static/badge.svg) ![linux](https://github.com/uperl/Linux-Inotify/workflows/linux/badge.svg)

Classes for supporting inotify in Linux Kernel >= 2.6.13

# DESCRIPTION

Linux::Inotify supports the new inotify interface of Linux which is a
replacement of dnotify. Beside the class Linux::Inotify there two helper
classes -- Linux::Inotify::Watch and Linux::Inotify::Event.

## class Linux::Inotify

The following code

```perl
use Linux::Inotify;
my $notifier = Linux::Inotify->new();
```

returns a new notifier.

```perl
my $watch = $notifier->add_watch('filename', Linux::Inotify::MASK);
```

adds a watch to filename (see below), where MASK is one of ACCESS, MODIFY,
ATTRIB, CLOSE\_WRITE, CLOSE\_NOWRITE, OPEN, MOVED\_FROM, MOVED\_TO, CREATE, DELETE,
DELETE\_SELF, UNMOUNT, Q\_OVERFLOW, IGNORED, ISDIR, ONESHOT, CLOSE, MOVE or
ALL\_EVENTS.

```perl
my @events = $notifier->read();
```

reads and decodes all available data and returns an array of
Linux::Inotify::Event objects (see below).

```
$notifier->close();
```

destroys the notifier and closes the associated file descriptor.

## class Linux::Inotify::Watch

The constructor new is usually not called directly but via the add\_watch method
of the notifier. An alternative constructor.

```perl
my $watch_clone = $watch->clone('filename');
```

creates an new watch for filename but shares the same $notifier and MASK. This
is indirectly used for recursing into subdirectories (see below). The
destructor

```
$watch->remove()
```

destroys the watch safely. It does not matter if the kernel has already removed
the watch itself, which may happen when the watched object has been deleted.

## class Linux::Inotify::Event

The constructor is not called directly but through the read method of
Linux::Inotify that returns an array of event objects.  An
Linux::Inotify::Event object has some interesting data members: mask, cookie
and name. The method

```
$event->fullname();
```

returns the full name of the file or directory not only the name relative to
the watch like the name member does contain.

```
$event->print();
```

prints the event to stdout in a human readable form.

```perl
my $new_watch = $event->add_watch();
```

creates a new watch for the file/directory of the event and shares the notifier
and MASK of the original watch, that has generated the event. That is useful
for recursing into subdirectories.

# AUTHOR

Original author: Torsten Werner

Current maintainer: Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2018-2022 by Torsten Werner <twerner@debian.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
