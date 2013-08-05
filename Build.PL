use Module::Build;

Module::Build -> new
(
	module_name    => 'Config::Tiny',
	license        => 'perl',
	dist_abstract  => 'Read/Write .ini style files with as little code as possible',
	dist_author    => 'Adam Kennedy <adamk@cpan.org>',
	build_requires =>
	{
		Test::More => 0.47,
#		Test::Pod  => 1.45, # Make it optional. See xt/pod.t
	},
	configure_requires =>
	{
		 Module::Build => 0.3800,
	},
	requires =>
	{
		'File::Temp' => 0.2301,
		'Path::Tiny' => 0.025,
		'perl'       => '5.8.1', # For the utf stuff.
		'strict'     => 0,
		'UNIVERSAL'  => 0,
		'utf8'       => 0,
		'vars'       => 0,
	},
) -> create_build_script();
