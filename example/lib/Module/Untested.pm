package Module::Untested;

use strict;
use warnings;
use Test::Tdd::Generator;

$Global::VARIABLE = 'foo';


sub foo {
	my $params = @_;

	Test::Tdd::Generator::create_test();

	return $params . $Global::VARIABLE;
}

1;