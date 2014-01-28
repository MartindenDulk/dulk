package dulk::Plugin::Foo;

#constructor
sub new {
  my $self = {};
  bless $self, 'dulk::Plugin::Foo';
  return $self;
}

use dulk::Base;

my $bot = new dulk::Base;

sub public {

#use Data::Dumper;
#die Dumper(@_);

    my ($plugin, $referrer, $raw, $nickname, $message, $destination, $type) = @_;


    print "/$message/";
    if ($message eq ':command') {
        $bot->relayMessage();
    }
}


1;