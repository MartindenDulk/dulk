
#########################################################
### 
### File: Socket.pm 
### Author: Martin den Dulk
### Contact: martin@dendulk.org
### 
### ======
### 
### This file was created for the dulk IRC bot repository
### on GitHub. See: https://github.com/MartindenDulk/dulk 
### 
#########################################################

package dulk::Socket;

sub new {
  my $self = {};
  bless $self, 'dulk::Socket';
  return $self;
}

#########################################################
### USED MODULES 
#########################################################
    use IO::Socket;
    use dulk::Base;


#########################################################
### GLOBAL VARIABLES 
#########################################################

    ### Main bot var
    my $bot = new dulk::Base;

    ### Server vars
    my $config = $bot->config();
    my $server = $config->{'server'}->{'address'};
    my $port = $config->{'server'}->{'port'};
    my @nicknames = ($config->{'server'}->{'nickname'}, $config->{'server'}->{'altnickname'});
    my $status = "";

    ### Global socket variable
    my $sock;

#########################################################
### SOCKET SUBROUTINES 
#########################################################

sub createSocket {

    $sock = new IO::Socket::INET(PeerAddr => $server,
                                    PeerPort => $port,
                                    Proto => 'tcp') or $bot->throwError("ERROR","Can't connect to IRC server",__PACKAGE__);
    ### Log on to the server. Add a check if connected

    print $sock "NICK $nicknames[0]\r\n";
    print $sock "USER $nicknames[0] 8 * :Perl IRC Hacks Robot\r\n";

    ### Read lines from the socket
    while (my $input = <$sock>) {
        ### When input is received, print it to the console. Might add logging here later on
        print $input;

        ### Check the numerical responses from the server
        if ($input =~ /376/) {
            ### 376 means we´ re logged in. Update the status
            $status = "connected";

            my $channels = $config->{'server'}->{'channels'}->{'channel'};

            if ($config->{'server'}->{'channels'}->{'channel'}->[1]) {
                ### If there's multiple channels in the config enter a for loop
                for (my $i=0; defined $channels->[$i]; $i++) {
                    rawMessage("JOIN $channels->[$i]");
                }
            } else {
            ### Only one channel in the config, join it
                    rawMessage("JOIN $channels");
            }

        }
        elsif ($input =~ /433/) {
            $bot->throwError("ERROR","Nickname is already in use.\n");
        }
        elsif ($input =~ /^PING(.*)$/i) {
            ### Return print for PING CTCP events, this prevents us from time-outs
            print $sock "PONG $1\r\n";
        }
        if ($status eq "connected" || $status eq "initialized") {
            ### We are connected. Do something with the input we are receiving

            if ($status eq "connected") {
                ### I had to create another status (initialized) because it kept trying to join channels when he was already on them.
                $status = "initialized";
                $bot->loadPlugins();
            }

            if ($status eq "initialized") {
                ### Start of extracting data that we need later on
                my @data = split(' ',$input);
                ($data[0]) = ($data[0] =~ m/(?<=:)(.*?)(?=!)/gi);

                ### Everything after 3 is the ´query´ of the user. Put that in a scalar
                my $query = join(' ',@data[ 3 .. $#data ]);

                if ($data[1] eq 'PRIVMSG' && $data[0] =~ m/^(?!dulkbot|StatServ)/gi) {
                    ### This qualifies as a message for now. Add a check for services / ignorelist etcetera later.
                    $query = substr $query, 1; # strip first char (:).

                    ### Parse our earlier collected data to our main messageReceived function
                    $bot->messageReceived($input, $data[0], $query, $data[2], $data[1]);
                  }
            }

        }
    }


    if ($@) { die "Mad error, yo: ". $@; }
    return $status;
}

#########################################################
### MESSAGE SUBROUTINES 
#########################################################

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