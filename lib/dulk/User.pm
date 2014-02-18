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

        ### Make sure we've got the latest user data
        loadUsers();

        if (!$users->{$nickname}) {
            ### User is unknown. Add him/her to the user xml file.
            $users->{$nickname}->{'rights'} = 'default';
            $users->{$nickname}->{'hostname'} = $hostname;

            saveUsers();

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
            return "true";
        } 
    }

    sub loadUsers {
        $users = XMLin("users.xml");
    }

    sub saveUsers {
            open my $fh, ">", "users.xml" or die "$0: open users.xml: $!";
            print $fh XMLout($users);
            close $fh or warn "$0: close users.xml: $!";
    }

    ### Subroutine to grant user rights
    sub grantUser {
        my ($package, $nickname, $command) = @_;

        if ($users->{$nickname}) {
            ### User is known, add the rights
            $users->{$nickname}->{'rights'} .= " $command";

            saveUsers();

            return "[INFO] $nickname has been granted '$command' priviledges";
        } else {
            ### User is unknown
            return "[ERROR] $nickname has not registered with me. Use '$settings->{'prefix'} register' to register.";
        }

    }

    ### Subroutine to revoke user rights
    sub revokeUser {
        my ($package, $nickname, $command) = @_;

        if ($users->{$nickname}) {
            ### User is known, add the rights
            $users->{$nickname}->{'rights'} =~ s/$command//gi;

            saveUsers();

            return "[INFO] $command priviledge has been revoked from $nickname";
        } else {
            ### User is unknown
            return "[ERROR] $nickname has not registered with me. Nothing was revoked.";
        }

    }

    if ($@) { throwError("ERROR","$@",__PACKAGE__); }

1;