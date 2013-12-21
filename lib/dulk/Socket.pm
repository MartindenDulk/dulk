package dulk::Socket;

#constructor
sub new {
  my $self = {};
  bless $self, 'dulk::Socket';
  return $self;
}

# We will use a raw socket to connect to the IRC server.
use IO::Socket;
use dulk::Base;

my $bot = new dulk::Base;

# The server to connect to and our details.
my $server = "irc.bracketnet.org";
my $nick = "dulkbot";
my $login = "dulkbot";
my $status = "";

# The channel which the bot will join.
my $channel = "#mojitotest";

# Connect to the IRC server.
sub createSocket {
    my $sock = new IO::Socket::INET(PeerAddr => $server,
                                    PeerPort => 6667,
                                    Proto => 'tcp') or $bot->throwError("Can't connect to IRC server",__PACKAGE__);
    # Log on to the server. Add a check if connected

    print $sock "NICK $nick\r\n";
    print $sock "USER $login 8 * :Perl IRC Hacks Robot\r\n";

    # Read lines from the server until it tells us we have connected.
    while (my $input = <$sock>) {
        # Check the numerical responses from the server.
        if ($input =~ /004/) {
            # We are now logged in. Return a true status
            $status = "connected";
            last;
        }
        elsif ($input =~ /433/) {
            $bot->throwError("Nickname is already in use.\n");
        }
    }
    if ($@) { die "Mad error, yo: ". $@; }
    return $status;
}

1;

__END__

## We need to add this below to a different module later on.

# Join the channel.
print $sock "JOIN $channel\r\n";

# Keep reading lines from the server.
while (my $input = <$sock>) {
    print $input;
    my @data = split(' ',$input);
    ($data[0]) = ($data[0] =~ m/(?<=:)(.*?)(?=!)/gi);

    if ($data[1] eq 'PRIVMSG' && $data[0] ne 'StatServ') { #Might want to add something that checks for services. Can't reply to that.
        print $sock "$data[1] $data[2] So, if I got this right. You are $data[0] and you just sent me $data[3]\r\n";
    }
}

1;








