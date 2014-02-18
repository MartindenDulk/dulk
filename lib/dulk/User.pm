#########################################################
### 
### File: User.pm
### Author: Martin den Dulk
### Contact: martin@dendulk.org
### 
### ======
### 
### This file was created for the dulk IRC bot repository
### on GitHub. See: https://github.com/MartindenDulk/dulk 
### 
#########################################################

    package dulk::User;

    sub new {
        my $self = {};
        bless $self, 'dulk::User';
        return $self;
    }

#########################################################
### USED MODULES
#########################################################

    ### XML::Simple for config purposes
    use XML::Simple;
    use dulk::Base;

#########################################################
### GLOBAL VARIABLES
#########################################################

    my $bot = new dulk::Base;
    my $users;

#########################################################
### USER SUBROUTINES
#########################################################

    sub registerUser {
        my @input = @_[ 1 .. $#_ ];
        my ($raw, $nickname, $message, $destination, $type, $hostname) = @input;

        ### Make sure we've got the latest user data
        loadUsers();

        if (!$users->{$nickname}) {
            ### User is unknown. Add him/her to the user xml file.
            $users->{$nickname}->{'rights'} = 'default';
            $users->{$nickname}->{'hostname'} = $hostname;

            open my $fh, ">", "users.xml" or die "$0: open users.xml: $!";
            print $fh XMLout($users);
            close $fh or warn "$0: close users.xml: $!";

            $bot->relayMessage("You've been added with the default priviledges. Welcome!", $destination);
        }
    }

    ### Subroutine to check if the user has the right priviledges
    sub userCan {
        my @input = @_[ 1 .. $#_ ];
        my ($command, $raw, $nickname, $message, $destination, $type, $hostname) = @input;

        ### Make sure we've got the latest user data
        loadUsers();

        my $checkUser = $users->{$nickname};
        if ($checkUser->{'rights'} =~ m/$command/gi && $checkUser->{'hostname'} eq $hostname) {
            print "true";
        } 
    }

    sub loadUsers {
        $users = XMLin("users.xml");
    }

    if ($@) { throwError("ERROR","$@",__PACKAGE__); }

1;