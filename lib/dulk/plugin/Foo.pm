package dulk::plugin::Foo;

#constructor
sub new {
  my $self = {};
  bless $self, 'dulk::plugin::Foo';
  return $self;
}

use dulk::Base;
my $bot = new dulk::Base;

sub public {
	my @query = @_[ 2 .. $#_ ];
    my ($raw, $nickname, $message, $destination, $type) = @query;
	

    if ($message eq 'foo') {
        $bot->relayMessage("Foo.pm: Foo","#mojitotest");
    }

}

@EXPORT = qw(public);

1;