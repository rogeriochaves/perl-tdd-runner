package Module::Untested;

use strict;
use warnings;
use Test::Tdd::Generator;

$Global::VARIABLE = 'foo';


sub untested_subroutine {
	my @params = @_;

	Test::Tdd::Generator::create_test('returns params plus foo');

	return join(',', @params) . $Global::VARIABLE;
}


sub another_untested_subroutine {
	Test::Tdd::Generator::create_test('returns the first param');

	return $_[0];
}

1;