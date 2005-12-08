package TestApp;

use Catalyst qw[SubRequest];

__PACKAGE__->config(
    name=>"subrequest test"
);

__PACKAGE__->setup();

    sub begin : Private {
        my ( $self, $c ) = @_;
        $c->res->body('1');
    }

    sub subtest : Global {
        my ( $self, $c ) = @_;
        my $subreq= $c->res->body().
                    $c->subreq('/normal/4');
        $c->res->body($subreq);
    }
  
    sub normal : Global {
        my ( $self, $c, $arg ) = @_;
        $c->res->body($c->res->body().$arg);
    }
    
    sub end : Private {
        my ( $self, $c ) = @_;
        $c->res->body($c->res->body().'3');
    }


1;
