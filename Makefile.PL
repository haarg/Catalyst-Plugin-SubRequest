use inc::Module::Install 0.67;

name 'Catalyst-Plugin-SubRequest';
all_from 'lib/Catalyst/Plugin/SubRequest.pm';

requires 'Catalyst::Runtime' => '5.7012';

requires 'Test::More';

auto_install;
WriteAll;
