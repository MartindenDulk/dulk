#########################################################
### 
### File: Foo.pm
### Author: Martin den Dulk
### Contact: martin@dendulk.org
### 
### ======
### 
### This file was created for the dulk IRC bot repository
### on GitHub. See: https://github.com/MartindenDulk/dulk 
### 
#########################################################

  package dulk::plugin::Foo;

  $|++;

#########################################################
### USED MODULES
#########################################################

  use dulk::Base;
  use dulk::User;

#########################################################
### GLOBAL VARIABLES
#########################################################

  my $bot = new dulk::Base;
  my $config = $bot->config();
  my $user = new dulk::User;

#########################################################
### SUBROUTINES
#########################################################

  sub new {
    my $self = {};
    bless $self, 'dulk::plugin::Foo';
    return $self;
  }

  ### This subroutine is called when the socket receives a message. Include a 'public' subroutine in your own scripts, save it in the plugin folder and it will be called after a rehash.
  sub public {
    my @input = @_[ 2 .. $#_ ];
      ### Strip incoming parameters, assign them to pretty variable names for your comfort
      my ($raw, $nickname, $message, $destination, $type) = @input;

      ### @query now holds your message splitted. You can check for input by checking the values of $query[x]
      my @query = split(' ',$message);

      ### If the first query array item matches your prefix in your config, start looking for replies.
      if ($config->{'settings'}->{'prefix'} && $query[0] eq $config->{'settings'}->{'prefix'}) {
        @query = @query[1 .. $#_];

        ### Dummy command. Boot the bot and say 'foo' in the channel he's on. It will show the response stated below.
        if ($query[0] eq 'foo') {
          ### Yep, 'foo' was said. Let's talk back!
          $bot->relayMessage("Hey! I just received $query[0] from $nickname on $destination. The full command was $message",$destination);
        }

        if ($query[0] eq 'foo') {
          ### Yep, 'foo' was said. Let's talk back!
          $bot->relayMessage("Hey! I just received $query[0] from $nickname on $destination. The full command was $message",$destination);
        }

        ### Authorized command. If the user has the rights flag 'bar' set, this will reply a message
        if ($query[0] eq 'bar' && $user->userCan("bar",@input)) {
          $bot->relayMessage("Yep, you're legit. Hooray for power!",$destination);
        } elsif ($query[0] eq 'bar' && !$user->userCan("bar",@input)) {
          $bot->relayMessage("Uh oh, you don´t have the ´bar´ rights/flag set in your users.xml. You don´t get a funny response ;(",$destination);
        }


      }
  }


#########################################################
### COMMAND REGISTRATION
#########################################################

  ### If you want your command to show up when you PM the bot with 'commands'. You need to register your command.
  ### The 'registerCommand' subroutine accepts two parameters: 'command' & 'help text'.
  ### If you rehash the bot, it will re-register these texts too and re-write the commands.xml

  $bot->registerCommand("foo","When a user says 'foo' on a channel. It will reply with some text");
  
1;