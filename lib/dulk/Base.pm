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
    use dulk::User;

#########################################################
### GLOBAL VARIABLES
#########################################################

    my $bot;
    my %plugins; 
    my %commands;
    my $status = "";
    my $config = config();
    my $settings = $config->{'settings'};
    my $server = $config->{'server'};
    my $user = new dulk::User;

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
        if (ref($_[0])) { shift @_; }

        (my $messageType, $message, $script) = @_;
        if ($settings->{'errorchannel'} && $status =~ m/connected|initialized/gi) {
            ### If a errochannel is defined in the config and we are connected, relay the errors to that channel
            relayMessage("[$messageType - $script] $message","$settings->{'errorchannel'}");
        } else {
            ### If not, print to console
            print "[$messageType - $script] $message\n";
        }
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
            if ($plugin->can('public')) {
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
        my @query = split(' ',$message);

        ### If the first query array item matches your prefix in your config, start looking for replies.
        if ($settings->{'prefix'} && $query[0] =~ m/$config->{'settings'}->{'prefix'}/gi) {
            @query = @query[1 .. $#_];

            ### Rehash command
            ### - The user that invokes this command needs to have the 'rehash' or the 'global-admin' right added in the users.xml. See the README for more information.
            if ($query[0] eq 'rehash' && $user->userCan("rehash",@input)) {
                throwError("INFO","Rehash was invoked. Starting now..",__PACKAGE__);
                reloadPlugins();
                throwError("INFO","Rehash has completed.",__PACKAGE__);
            }

            ### - The user that invokes these two commands needs to have the 'admin-users' or the 'global-admin' right added in the users.xml. See the README for more information.
            if ($query[0] eq 'grant' && $user->userCan("admin-users",@input)) {
                my $grantMessage = $user->grantUser($query[1], $query[2], $destination);
                relayMessage($grantMessage,$destination);
            }

            if ($query[0] eq 'revoke' && $user->userCan("admin-users",@input)) {
                my $revokeMessage = $user->revokeUser($query[1], $query[2], $destination);
                relayMessage($revokeMessage,$destination);
            }

            ### Help command
            if ($query[0] eq 'help') {
                relayMessage("Curious on what I can do? Try PMing me with 'commands'.",$destination);
            }

            ### Register command
            if ($query[0] eq 'register') {
                $user->registerUser(@input);
            }


        }
        if ($destination =~ m/($server->{'nickname'}|$server->{'altnickname'})/) {
            if ($query[0] eq 'commands') {
                for my $command (keys %commands) {

                    my $commandMessage = "['$command']";
                    $commandMessage .= ($commands{$command}->{"rights"}) ? "[$commands{$command}->{'rights'}] " : " ";
                    $commandMessage .= $commands{$command}->{'description'};

                    relayMessage("$commandMessage",$nickname);
                }
            }
        }

    }


#########################################################
### REGISTRATION OF COMMANDS
#########################################################

    registerCommand("dulk::Base","commands","Displays this lovely help text");
    registerCommand("dulk::Base","register","Register yourself as a user.");
    registerCommand("dulk::Base","grant/revoke","Grant or revoke user rights","global-admin");
    registerCommand("dulk::Base","rehash","Command used to reload all scripts & config files","global-admin");

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

    sub registerCommand {
        my ($package, $command, $help, $rights) = @_;
        $commands{$command}{'description'} = "$help";
        if ($rights) {
            $commands{$command}{'rights'} = "$rights";
        }
    }

    sub config {
        return XMLin("config.xml");
    }

    if ($@) { throwError("ERROR","$@",__PACKAGE__); }

1;