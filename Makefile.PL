require 5.000;
use ExtUtils::MakeMaker;
WriteMakefile(
	'NAME'         => 'Config::Tiny',
	'VERSION_FROM' => 'lib/Config/Tiny.pm',
	'PREREQ_PM'    => {
		# Modules for the tests
		Test::More => 0,
		FindBin    => 0,
	},
	($] >= 5.005) ? (
		'AUTHOR'   => 'Adam Kennedy (cpan@ali.as)',
		'ABSTRACT' => 'Read/Write .ini style files with as little code as possible',
	) : (),
);
