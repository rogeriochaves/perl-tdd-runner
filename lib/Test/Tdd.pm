package Test::Tdd;

# ABSTRACT: run tests continuously, detecting changes

use strict;
use warnings;
use Test::Tdd::Runner;
use Data::Dumper;
use Getopt::Long;
Getopt::Long::Configure('bundling');

=head1 NAME
Test::Tdd - Run tests continuously, detecting changes
=head1 SYNOPSIS
  $ provetdd t/path/to/Test.t
=cut

my $help;
my @watch = ();
my @includes = ();
GetOptions(
	'I=s@'     => \@includes,
	'watch=s@' => \@watch,
	'help'     => \$help,
) or show_usage();
show_usage() if $help;

@watch = split(/,/, join(',', @watch));
@watch = ('.') unless @watch;

@INC = (@INC, @includes);

my @test_files = @ARGV;
show_usage() unless @test_files;

Test::Tdd::Runner::start(\@watch, \@test_files);


sub show_usage {
	print <<EOF;
Usage: provetdd <options> <tests to run>
(e.g. provetdd --watch lib t/Test.t)

Options:
  -I            Library paths to include
  -w, --watch   Folders to watch, default to current folder.
  -h, --help    Print this message.
EOF
	exit 1;
}

1;
