package dulk::Base;

#constructor
sub new {
  my $self = {};
  bless $self, 'dulk::Base';
  return $self;
}


# Socket connect.
sub connect {
    require dulk::Socket;
    my $bot = new dulk::Socket;
    $socket = $bot->createSocket();
    setStatus($socket);
}

# Error handling. Just a print to console later. We could make this configurable. Perhaps relayed to the debug channel?
sub throwError {
    (my $errorMessage, $errorScript) = @_;
    print "[ERROR - $errorScript] $errorMessage\n";
}

# Status handling. Set & Get.
my $status = "";
sub setStatus {
    (my $statusMessage) = @_;
    if (defined $statusMessage) { $status = $statusMessage."\n"; }
    else { throwError("Tried to set the status with an undefined message",__PACKAGE__); }
}

sub getStatus {
    if (defined $status) { return $status; }
    else { return "Status unknown."; }
}


1;








