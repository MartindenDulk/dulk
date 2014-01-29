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
my $config = $bot->config();
my $server = $config->{'server'}->{'address'};
my $port = $config->{'server'}->{'port'};
my $nick = $config->{'server'}->{'nickname'};
my $login = $nick;
my $status = "";

# Global socket variable
my $sock;

# Connect to the IRC server.
sub createSocket {

    $sock = new IO::Socket::INET(PeerAddr => $server,
                                    PeerPort => $port,
                                    Proto => 'tcp') or $bot->throwError("ERROR","Can't connect to IRC server",__PACKAGE__);
    # Log on to the server. Add a check if connected

    print $sock "NICK $nick\r\n";
    print $sock "USER $login 8 * :Perl IRC Hacks Robot\r\n";

    # Read lines from the server until it tells us we have connected.
    while (my $input = <$sock>) {
        print $input;
        # Check the numerical responses from the server.
        if ($input =~ /376/) {
            # We are now logged in. Return a true status
            $status = "connected";

            my $channels = $config->{'server'}->{'channels'}->{'channel'};

            for (my $i=0; defined $channels->[$i]; $i++) {
                rawMessage("JOIN $channels->[$i]");
            }


        }
        elsif ($input =~ /433/) {
            $bot->throwError("ERROR","Nickname is already in use.\n");
        }
        elsif ($input =~ /^PING(.*)$/i) {
            print $sock "PONG $1\r\n";
        }
        if ($status eq "connected" || $status eq "initialized") {
            # We are connected. Do something with the input we are receiving.

            if ($status eq "connected") {
                # I had to create another status (initialized) because it kept trying to join channels when he was already on them.
                $status = "initialized";
                $bot->loadPlugins();
            }

            if ($status eq "initialized") {
                my @data = split(' ',$input);
                ($data[0]) = ($data[0] =~ m/(?<=:)(.*?)(?=!)/gi);
                my $query = join(' ',@data[ 3 .. $#data ]);

                if ($data[1] eq 'PRIVMSG' && $data[0] =~ m/^(?!dulkbot|StatServ)/gi) {
                    # This qualifies as a message for now. Add a check for services / ignorelist etcetera later.
                    $query = substr $query, 1; # strip first char (:).
                    $bot->messageReceived($input, $data[0], $query, $data[2], $data[1]);
                  }
            }

        }
    }


    if ($@) { die "Mad error, yo: ". $@; }
    return $status;
}

sub relayMessage {

    ### The first arrItem is a hashref, sometimes (depends on where this sub is called from) the second one is a hashref too.
    ### If someone knows a better way to remove these ref items, let me know please.
    my @query = ($_[1] =~ m/\:\:/) ? @_[ 2 .. $#_ ] : @_[ 1 .. $#_ ];
    my ($message, $destination, $type) = @query;

        ### If no type defined, make it a privmsg by default
        $type = ($type) ? $type : "PRIVMSG";

        ## For testing, will remove later
        #print "\n\n\n0:: $query[0] // 1:: $query[1] // 2:: $query[2] // 3:: $query[3] // 4:: $query[4] // 5:: $query[5] // 6:: $query[6]\n\n\n";

        ### Print the response to the socket
        print $sock "$type $destination :$message\r\n";
}

sub rawMessage {
    my @query = @_;
    if ($#query > 0) {
        ### If the size is bigger than 0 it might contain plugin references
        @query = ($_[1] =~ m/\:\:/) ? @_[ 2 .. $#_ ] : @_[ 1 .. $#_ ];
    }

    my ($raw) = $query[0];

    print $sock "$raw\r\n";
}

1;