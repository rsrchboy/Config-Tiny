package Config::Tiny;

# If you thought Config::Simple was small...

require 5.005;
use strict;

use vars qw{$VERSION $errstr};
BEGIN {
	$VERSION = 1.0;
	$errstr = '';
}

# Create an empty object
sub new { bless { }, $_[0] }

# Create an object from a file
sub read {
	my $class = shift;

	# Check the file
	my $file = shift or return $class->_error( 'You did not specify a file name' );
	return $class->_error( "File '$file' does not exist" ) unless -e $file;
	return $class->_error( "'$file' is a directory, not a file" ) unless -f $file;
	return $class->_error( "Insufficient permissions to read '$file'" ) unless -r $file;

	# Read in the file
	local $/ = undef;
	open( CFG, $file ) or return $class->_error( "Failed to open file '$file': $!" );
	my $contents = <CFG>;
	close( CFG );

	# Parse and return
	return $class->read_string( $contents );
}	

# Create an object from a string
sub read_string {
	my $class = shift;
	my $string = shift;

	# Create the empty object
	my $self = bless {}, $class;
	
	# Parse the file
	my $ns = '_';
	my $counter = 0;
	foreach ( split /(?:\015\012|\015|\012)/, $string ) {
		$counter++;
		
		# Skip comments and empty lines
		next if /^\s*(?:\#|\;)/ || /^\s*$/;

		# Handle section headers
		if ( /^\s*\[(.+?)\]\s*/ ) {
			$ns = $1;
			next;
		}
		
		# Handle properties
		if ( /^\s*([^=]+?)\s*=\s*(.*)/ ) {
			$self->{$ns}->{$1} = $2;
			next;
		}
		
		return $self->_error( "Syntax error at line $counter: $_" );
	}
	
	return $self;
}

# Save an object to a file
sub write {
	my $self = shift;
	my $file = shift or return $self->_error( 'No file name provided' );

	# Get the contents of the file
	my $contents = $self->write_string();
	
	# Write it to the file
	open ( CFG, ">$file" )
		or return $self->_error( "Failed to open file '$file' for writing: $!" );
	print CFG $contents;
	close( CFG );

	return 1;	
}

# Save an object to a string
sub write_string {
	my $self = shift;
	
	my $contents = '';
	foreach my $section ( sort { (($b eq '_') <=> ($a eq '_')) || ($a cmp $b) } keys %$self ) {
		my $block = $self->{$section};
		$contents .= "\n" if length $contents;
		$contents .= "[$section]\n" unless $section eq '_';
		foreach my $property ( sort keys %$block ) {
			$contents .= "$property=$block->{$property}\n";
		}
	}
	
	return $contents;
}
	
# Error handling
sub errstr { $errstr }
sub _error { $errstr = $_[1]; return undef }

1;

__END__

=pod

=head1 NAME

Config::Tiny - Read/Write .ini style files with as little code as possible

=head1 SYNOPSIS

    # In your configuration file
    rootproperty=blah
    
    [section]
    one=twp
    three= four
    Foo =Bar
    empty=

    # In your program
    use Config::Tiny;

    # Create a config
    my $Config = Config::Tiny->new();

    # Open the config
    $Config = Config::Tiny->read( 'file.conf' );

    # Reading properties
    my $rootproperty = $Config->{_}->{rootproperty};
    my $one = $Config->{section}->{one};
    my $Foo = $Config->{section}->{Foo};

    # Changing data
    $Config->{newsection} = { this => 'that' }; # Add a section
    $Config->{section}->{Foo} = 'Not Bar!';     # Change a value
    delete $Config->{_};                        # Delete a value or section

    # Save a config
    $Config->write( 'file.conf' );

=head1 DESCRIPTION

Config::Tiny is a perl class to read and write .ini style configuration files
with as little code as possible, reducing load time and memory overhead.
Memory usage is normally scoffed at in Perl, but in my opinion should be
at least kept in mind.

This module is primarily for reading human written files, and anything we
write shouldn't need to have documentation/comments. If you need something
with more power, move up to Config::Simple, Config::General or one of the
many other Config:: modules.

=head1 CONFIGURATION FILE SYNTAX

Files are the same as windows .ini files, for example.

	[section]
	var1=value1
	var2=value2

If a property is outside of a section, it will be assigned to the root 
section, available at C<$Config->{_}>.

Lines starting with '#' or ';' are comments.

When writing back to the config file, any comments etc are discarded.

=head1 METHODS

=head2 new()

The constructor C<new()> creates and returns an empty Config::Tiny object.

=head2 read( $filename )

The C<read()> constructor reads a config file, and returns a new Config::Tiny
object containing the properties in the file. Returns the object on success.
Returns C<undef> on error.

=head2 read_string( $string );

The C<read_string()> takes as argument the contents of a config file as a string
and returns the Config::Tiny object for it.

=head2 write()

The C<write( $filename )> generates the file for the properties, and writes it
to disk. Returns true on success. Returns C<undef> on error.

=head2 write_string()

Generates the file for the object and returns it as a string.

=head2 errstr()

When an error occurs, you can retrieve the error message either from the
C<$Config::Tiny::errstr> variable, or using the C<errstr()> method.

=head1 SUPPORT

Contact the author

=head1 AUTHOR

        Adam Kennedy ( maintainer )
        cpan@ali.as
        http://ali.as/

Thanks to Sherzod Ruzmetov <sherzodr@cpan.org> for Config::Simple, which 
inspired this module.

=head1 SEE ALSO

C<Config::Simple>, C<Config::General>

=head1 COPYRIGHT

Copyright (c) 2002 Adam Kennedy. All rights reserved.
This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut
