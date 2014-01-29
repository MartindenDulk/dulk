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

print "\n\n FOO PUBLIC CALLED \n\n";

	my @query = @_[ 2 .. $#_ ];
    my ($raw, $nickname, $message, $destination, $type) = @query;
	

    if ($message eq 'foo') {
        $bot->relayMessage("Foo.pm: Foo","#mojitotest");
    }

    if ($message eq 'martin') {
        $bot->relayMessage("Koffie? :D","#mojitotest");
    }


}

print "\n\n\n\n\nHEEEEEEEEEY\n\n\n\n\n";
#@EXPORT = qw(public);

1;