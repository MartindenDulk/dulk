package dulk::Base;

    # global variables
    my $bot;
    my %plugins; 


    ### XML::Simple for config purposes
    use XML::Simple;

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
        (my $messageType, $message, $script) = @_;
        print "[$messageType - $script] $message\n";
    }

    # Status handling. Set & Get.
    my $status = "";

    sub setStatus {
        (my $statusMessage) = @_;
        if (defined $statusMessage) { $status = $statusMessage."\n"; }
        else { throwError("ERROR","Tried to set the status with an undefined message",__PACKAGE__); }
    }

    sub getStatus {
        if (defined $status) { return $status; }
        else { return "Status unknown."; }
    }

    sub messageReceived {
        my @message = @_;

        for my $plugin (keys %plugins) {
            if ($plugin->can(public)) {
                $plugin->public(@message);
            } 
        }

        ## also parse it to dulk::Base
        public(@message);

    }

    sub relayMessage {
        $bot->relayMessage(@_);
    }

    sub rawMessage {
        $bot->rawMessage(@_);
    }


    sub loadPlugins {

        my $dir = "lib/dulk/plugin";
        opendir (DIR, $dir) or throwError("ERROR","Error opening plugin folder:$!",__PACKAGE__);

        while (my $file = readdir(DIR)) {
            if ($file =~ m/(.*?)(?:\.pm|\.pl)/gi) {

                # Add plugin to plugins hash
                $plugins{"dulk::plugin::$1"} = "$file";
                require "$file";

            }
        }
        closedir(DIR);
    }

    sub reloadPlugins {
        # Clear previous stored data
        for my $plugin (keys %plugins) {
            # remove already loaded plugins from INC
            delete $INC{ $plugins{$plugin} };
        }

        # once INC is clear, clear the plugins hash also
        undef %plugins;

        # load the plugins again
        loadPlugins();
    }

    sub config {
        return XMLin("config.xml");
    }


    sub public {
        my @input = @_[ 1 .. $#_ ];
        my ($raw, $nickname, $message, $destination, $type) = @input;

        if ($message eq 'rehash') {
            throwError("INFO","Rehash was invoked. Starting now..",__PACKAGE__);
            reloadPlugins();
            throwError("INFO","Rehash has completed.",__PACKAGE__);
        }

        ### For testing, will remove later
        #print "\n\n\n0:: $input[0] // 1:: $input[1] // 2:: $input[2] // 3:: $input[3] // 4:: $input[4] // 5:: $input[5] // 6:: $input[6]\n\n\n";

    }

    if ($@) { throwError("ERROR","$@",__PACKAGE__); }
1;








