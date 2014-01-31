#########################################################
### 
### File: Base.pm
### Author: Martin den Dulk
### Contact: martin@dendulk.org
### 
### ======
### 
### This file was created for the dulk IRC bot repository
### on GitHub. See: https://github.com/MartindenDulk/dulk 
### 
#########################################################

    package dulk::Base;

    sub new {
        my $self = {};
        bless $self, 'dulk::Base';
        return $self;
    }

#########################################################
### USED MODULES
#########################################################

    ### XML::Simple for config purposes
    use XML::Simple;

#########################################################
### GLOBAL VARIABLES
#########################################################

    my $bot;
    my %plugins; 
    my $status = "";

#########################################################
### CONNECT SUBROUTINES
#########################################################

    ### Connect to the socket using dulk::Socket
    sub connect {
        require dulk::Socket;
        $bot = new dulk::Socket;
        $socket = $bot->createSocket();
        setStatus($socket);
    }

#########################################################
### ERROR HANDLING
#########################################################

    ### When an error occurs it's printed to console. We could make this configurable. Perhaps relayed to the debug channel?
    sub throwError {
        (my $messageType, $message, $script) = @_;
        print "[$messageType - $script] $message\n";
    }

#########################################################
### STATUS HANDLING
#########################################################

    sub setStatus {
        (my $statusMessage) = @_;
        if (defined $statusMessage) { $status = $statusMessage."\n"; }
        else { throwError("ERROR","Tried to set the status with an undefined message",__PACKAGE__); }
    }

    sub getStatus {
        if (defined $status) { return $status; }
        else { return "Status unknown."; }
    }

#########################################################
### MESSAGE SUBROUTINES
#########################################################

    sub messageReceived {
        my @message = @_;

        ### When a message is received, check the global plugin var if the looped plugin has a public subroutine.
        ### If so, relay the message to that subroutine.
        for my $plugin (keys %plugins) {
            if ($plugin->can(public)) {
                $plugin->public(@message);
            } 
        }

        ### also parse it to dulk::Base
        public(@message);

    }

    sub relayMessage {
        $bot->relayMessage(@_);
    }

    sub rawMessage {
        $bot->rawMessage(@_);
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

#########################################################
### PLUGIN/CONFIG SUBROUTINES
#########################################################

    sub loadPlugins {

        ### Check the lib/dulk/plugin directory for .pm|.pl files. If found, load it/them
        my $dir = "lib/dulk/plugin";
        opendir (DIR, $dir) or throwError("ERROR","Error opening plugin folder:$!",__PACKAGE__);

        while (my $file = readdir(DIR)) {
            if ($file =~ m/(.*?)(?:\.pm|\.pl)/gi) {

                ### Add found plugin file to plugins hash
                $plugins{"dulk::plugin::$1"} = "$file";
                require "$file";

            }
        }
        closedir(DIR);
    }

    sub reloadPlugins {
        ### Start off fresh, delete all loaded plugins from INC
        for my $plugin (keys %plugins) {
            delete $INC{ $plugins{$plugin} };
        }

        ### once INC is clear, clear the plugins hash also
        undef %plugins;

        ### load the plugins again
        loadPlugins();
    }

    sub config {
        return XMLin("config.xml");
    }

    if ($@) { throwError("ERROR","$@",__PACKAGE__); }

1;