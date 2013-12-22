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
        print $input;
        # Check the numerical responses from the server.
        if ($input =~ /004/) {
            # We are now logged in. Return a true status
            $status = "connected";
        }
        elsif ($input =~ /433/) {
            $bot->throwError("Nickname is already in use.\n");
        }
        elsif ($input =~ /^PING(.*)$/i) {
            print $sock "PONG $1\r\n";
        }
        if ($status eq "connected" || $status eq "initialized") {
            # We are connected. Do something with the input we are receiving.

            if ($status eq "connected") {
                # I had to create another status (initialized) because it kept trying to join channels when he was already on them.
                print $sock "JOIN $channel\r\n";
                $status = "initialized";
            }

            if ($status eq "initialized") {
                my @data = split(' ',$input);
                ($data[0]) = ($data[0] =~ m/(?<=:)(.*?)(?=!)/gi);

                if ($data[1] eq 'PRIVMSG' && $data[0] =~ m/^(?!dulkbot|StatServ)/gi) { #Might want to add something that checks for services. Can't reply to that.
                    print $sock "$data[1] $data[2] So, if I got this right. You are $data[0] and you just sent me $data[3]\r\n";
                }
            }

        }
    }

    if ($@) { die "Mad error, yo: ". $@; }
    return $status;
}

1;