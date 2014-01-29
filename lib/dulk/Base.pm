package dulk::Base;

    # global variables
    my $bot;
    my @plugins; 
    #constructor
    sub new {
      my $self = {};
      bless $self, 'dulk::Base';
      return $self;
    }


    # Socket connect.
    sub connect {
        require dulk::Socket;
        $bot = new dulk::Socket;
        $socket = $bot->createSocket();
        setStatus($socket);
    }

    # Error handling. Just a print to console. We could make this configurable. Perhaps relayed to the debug channel?
    sub throwError {
        (my $errorMessage, $errorScript) = @_;
        print "[ERROR - $errorScript] $errorMessage\n";
    }

    # Status handling. Set & Get.
    my $status = "";
    sub setStatus {
        (my $statusMessage) = @_;
        if (defined $statusMessage) { $status = $statusMessage."\n"; }
        else { throwError("Tried to set the status with an undefined message",__PACKAGE__); }
    }

    sub getStatus {
        if (defined $status) { return $status; }
        else { return "Status unknown."; }
    }

    sub messageReceived {
      my @message = @_;

      foreach(@plugins) {
        $_->public(@message);
      }

      ## also parse it to dulk::Base
      public(@message);

    }

    sub relayMessage {
      $bot->relayMessage(@_);
    }


    sub public {
      my @query = @_[ 1 .. $#_ ];
        my ($raw, $nickname, $message, $destination, $type) = @query;

        if ($message eq 'foo') {
          relayMessage("message","#destination");
        }

        ### For testing, will remove later
        #print "\n\n\n0:: $query[0] // 1:: $query[1] // 2:: $query[2] // 3:: $query[3] // 4:: $query[4] // 5:: $query[5] // 6:: $query[6]\n\n\n";
      
    }
    if ($!) { throwError("$!",__PACKAGE__); }
1;








