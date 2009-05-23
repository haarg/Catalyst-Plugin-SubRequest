use inc::Module::Install 0.87;

name 'Catalyst-Plugin-SubRequest';
all_from 'lib/Catalyst/Plugin/SubRequest.pm';

requires 'Catalyst::Runtime' => '5.7012';

requires 'Test::More';

auto_install;
resources repository => 'http://dev.catalyst.perl.org/repos/Catalyst/trunk/Catalyst-Plugin-SubRequest/';

WriteAll;
