package Test::Tdd;

# ABSTRACT: run tests continuously, detecting changes

use strict;
use warnings;
use Test::Tdd::Runner;
use Data::Dumper;
use Getopt::Long;

=head1 NAME
Test::Tdd - Run tests continuously, detecting changes
=head1 SYNOPSIS
	$ provetdd t/path/to/Test.t
=cut

my $help;
my @watch = ();
GetOptions(
	"help"		 => \$help,
	"watch=s@"  => \@watch,
) or show_usage();
show_usage() if $help;

@watch = split(/,/, join(',', @watch));
@watch = (".") unless @watch;

my @test_files = @ARGV;

show_usage() unless @test_files;

Test::Tdd::Runner::start(\@watch, \@test_files);


sub show_usage {
	print <<EOF;
Usage: provetdd <options> <tests to run>
(e.g. provetdd --watch lib t/Test.t)

Options:
  --watch|-w    Folders to watch, default to current folder.
  --help|-h     Print this message.
EOF
	exit 1;
}

1;
