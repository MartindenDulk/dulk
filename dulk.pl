#!/usr/bin/perl -w
# irc.pl
# A simple IRC robot.
# Usage: perl irc.pl


# define our own lib dir
use FindBin qw($RealBin);
use lib "$RealBin/lib/";

# Add some Modules we need
use strict;
use Data::Dumper;
use dulk::Base; # Handles socket connections / Errors / ...

# Global variable 
my $bot = new dulk::Base;

# Connect and check status if it´s connected
my $status = $bot->connect();

if ($bot->getStatus() eq "connected") {
    print "We are connected, start listening for messages.";
}

