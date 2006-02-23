use inc::Module::Install;

name           'Config-Tiny';
all_from       'lib/Config/Tiny.pm';
requires       'FindBin' => 0;
build_requires 'Test::More' => '0.47';

auto_install;
WriteAll;
