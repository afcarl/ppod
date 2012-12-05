# OpenBSD Manpages #

I may catch some flak for saying so, but I find the FreeBSD and OpenBSD
manpages superior to those of GNU/Linux (sorry NetBSD, I haven't tried yours
out just yet). This little handy script checks out the OpenBSD manpages so
that you can use them as reference. The OpenBSD devs are famous for the
adherence to standards and it is a safe bet that what you write will end up
being more portable. It is also nice to check for likely compatibility for
command flags when writing shell scripts.

This is how I use it:

    mkdir ~/.oman
    ./oman.sh 5.1 ~/.oman

You will then have an up-to-date `usr` hierarchy to be used with `man`:

    man --manpath=usr/share/man

For good measure, why not throw in an `oman` alias in your shell rc? Maybe
even an `oapropos` alias?

Some warnings, there is a fairly big chance that you don't have all the
manpages that would be present on a real OpenBSD install, but at least for my
purposes this approach has proven to be enough. Also, note that you need to
enter the version number manually. Check http://www.openbsd.org/ for the
latest version number. Why not buy a CD and a T-shirt while you are at it?
