#!/usr/bin/perl

# Formal testing for Config::Tiny

use strict;
use lib '../../modules'; # For development testing
use lib '../lib'; # For installation testing
use UNIVERSAL 'isa';
use Test::More tests => 23;

# Set up any needed globals
use vars qw{$loaded};
BEGIN {
	$loaded = 0;
	$| = 1;
}




# Check their perl version
BEGIN {
	ok( $] >= 5.005, "Your perl is new enough" );
}
	




# Does the module load
END { ok( 0, 'Config::Tiny loads' ) unless $loaded; }
use Config::Tiny;
$loaded = 1;
ok( 1, 'Config::Tiny loads' );




# Test trivial creation
my $Trivial = Config::Tiny->new();
ok( $Trivial, '->new returns true' );
ok( ref $Trivial, '->new returns a reference' );
ok( isa( $Trivial, 'HASH' ), '->new returns a hash reference' );
ok( isa( $Trivial, 'Config::Tiny' ), '->new returns a Config::Tiny object' );
ok( scalar keys %$Trivial == 0, '->new returns an empty object' );

# Try to read in a config
my $Config = Config::Tiny->read( './test.conf' );
ok( $Config, '->read returns true' );
ok( ref $Config, '->read returns a reference' );
ok( isa( $Config, 'HASH' ), '->read returns a hash reference' );
ok( isa( $Config, 'Config::Tiny' ), '->read returns a Config::Tiny object' );

# Check the structure of the config
my $expected = {
	'_' => {
		root => 'something',
		},
	section => {
		one => 'two',
		Foo => 'Bar',
		this => 'Your Mother!',
		blank => '',
		},
	'Section Two' => {
		'something else' => 'blah',
		'remove' => 'whitespace',
		},
	};
bless $expected, 'Config::Tiny';
is_deeply( $Config, $expected, 'Config structure matches expected' );

# Add some stuff to the trivial config and check write_string() for it
$Trivial->{_} = { root1 => 'root2' };
$Trivial->{section} = {
	foo => 'bar',
	this => 'that',
	blank => '',
	};
$Trivial->{section2} = {
	'this little piggy' => 'went to market'
	};
my $string = <<END;
root1=root2

[section]
blank=
foo=bar
this=that

[section2]
this little piggy=went to market
END

# Test read_string
my $Read = Config::Tiny->read_string( $string );
ok( $Read, '->read_string returns true' );
is_deeply( $Read, $Trivial, '->read_string returns expected value' );

my $generated = $Trivial->write_string();
ok( length $generated, '->write_string returns something' );
ok( $generated eq $string, '->write_string returns the correct file contents' );

# Try to write a file
my $rv = $Trivial->write( './test2.conf' );
ok( $rv, '->write returned true' );
ok( -e 'test2.conf', '->write actually created a file' );

# Try to read the config back in
$Read = Config::Tiny->read( './test2.conf' );
ok( $Read, '->read of what we wrote returns true' );
ok( ref $Read, '->read of what we wrote returns a reference' );
ok( isa( $Read, 'HASH' ), '->read of what we wrote returns a hash reference' );
ok( isa( $Read, 'Config::Tiny' ), '->read of what we wrote returns a Config::Tiny object' );

# Check the structure of what we read back in
is_deeply( $Read, $Trivial, 'What we read matches what we wrote out' );





END {
	# Clean up
	unlink './test2.conf';
}
1;
