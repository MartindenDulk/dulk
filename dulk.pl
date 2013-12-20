#!/usr/bin/perl -w
# irc.pl
# A simple IRC robot.
# Usage: perl irc.pl

use strict;

# We will use a raw socket to connect to the IRC server.
use IO::Socket;
use Data::Dumper;

# The server to connect to and our details.
my $server = "irc.bracketnet.org";
my $nick = "dulkbot";
my $login = "dulkbot";

# The channel which the bot will join.
my $channel = "#mojitotest";

# Connect to the IRC server.
my $sock = new IO::Socket::INET(PeerAddr => $server,
                                PeerPort => 6667,
                                Proto => 'tcp') or
                                    die "Can't connect\n";

# Log on to the server.
print $sock "NICK $nick\r\n";
print $sock "USER $login 8 * :Perl IRC Hacks Robot\r\n";

# Read lines from the server until it tells us we have connected.
while (my $input = <$sock>) {
    # Check the numerical responses from the server.
    if ($input =~ /004/) {
        # We are now logged in.
        last;
    }
    elsif ($input =~ /433/) {
        die "Nickname is already in use.";
    }
}

# Join the channel.
print $sock "JOIN $channel\r\n";

# Keep reading lines from the server.
while (my $input = <$sock>) {
    print $input;
    while( $input =~ m/(?<raw_message>\:(?<source>((?<nick>[^!]+)![~]{0,1}(?<user>[^@]+)@)?(?<host>[^\s]+)) (?<command>[^\s]+)( )?(?<parameters>[^:]+){0,1}(:)?(?<text>[^\r^\n]+)?)/gi) {
        my ($raw, $fullhost, $ident, $nickname, $username, $hostname, $command, $acht, $channel, $tien, $query) = ($1 ... $11);
        #1/raw 2/hostname 3/ident 4/nickname 5/nickname 6/hostname 7/command 8/leeg 9/channel 10/leeg 11/query
        if (defined $nick && $command eq 'PRIVMSG') {
            print $sock "PRIVMSG #mojitotest :Hey $nickname!\r\n";
        }
    }

}

