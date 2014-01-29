package dulk::plugin::Foo;

$|++;

#constructor
sub new {
  my $self = {};
  bless $self, 'dulk::plugin::Foo';
  return $self;
}

use dulk::Base;
my $bot = new dulk::Base;

sub public {

  my @input = @_[ 2 .. $#_ ];
    my ($raw, $nickname, $message, $destination, $type) = @input;

    ### @query now holds your message splitted. You can check for input by checking the values of $query[x]
    my @query = split(' ',$message);

    if ($query[0] eq 'foo') {
      ### If the word 'foo' is said on a channel where the bot is. It will relay a message to that channel
      $bot->relayMessage("Hey! I just received $query[0] from $nickname on $destination. The full command was $message",$destination);
    }



}

1;