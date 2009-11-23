package TestApp::Controller::Root;
use strict;
use warnings;

use base qw/Catalyst::Controller/;

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

sub subtest_params : Global {
    my ( $self, $c ) = @_;
    my $before = $c->req->params->{value};
    my $subreq = $c->subreq('/normal/2');
    my $after = $c->req->params->{value};
    $c->res->body($c->res->body().$after);
}

sub end : Private {
    my ( $self, $c ) = @_;
    $c->res->body($c->res->body().'3');
}

1;

