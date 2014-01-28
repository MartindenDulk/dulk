package dulk::Base;

    # global variables
    my $bot;

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

    sub loadPlugins {
        my $dir = "lib/dulk/plugin";
        opendir (DIR, $dir) or throwError("Error opening plugin folder:$!",__PACKAGE__);

        while (my $file = readdir(DIR)) {
          if ($file =~ m/(.*?)(?:\.pm|\.pl)/gi) {
          my $newModule = $1;
            require "$file";
              push(@plugins, "dulk::Plugin::$newModule");
          }
        }
        closedir(DIR);
    }

    sub messageReceived {
      my @message = @_;

      foreach(@plugins) {
        $_->public(@message);
      }

    }

    sub relayMessage {
      $bot->relayMessage("test");
    }
1;








