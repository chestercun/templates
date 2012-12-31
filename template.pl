#!/usr/bin/perl
use strict;
use warnings;

# what kind of project are we initializing?
my $type = ($ARGV[0]) ? $ARGV[0] : -1;

# supported languages
my $templates = {
	1 => "C",
	2 => "C++",
  3 => "Ruby",
  4 => "Perl",
};


# check if we support their language
unless ($templates->{$type}) {
  print "\n\tUsage: perl templates.pl #number# \n";
  print "\n";
  print "\t\tTypes:\n";
  foreach my $key (sort keys %$templates) {
  	print "\t$key: $templates->{$key}\n";
  }
  print "\n";
}

# helper function
sub textFile {
	my $filename = shift;     # string
	my $text = shift;         # array ref
	open FILE, ">$filename" or die $!;
	if (ref($text) eq 'ARRAY') {
		foreach my $line (@$text) {
			print FILE $line;
    }
  } else {
  	print FILE $text;
  }
  close FILE;
}

if ($type == 1) {
  ##########################################
  #
  #                   C
  #
  ##########################################

textFile "test.sh", qq{
make all clean
./a.out command line args here
};

textFile "Makefile", qq{
CFLAGS:-Wall -g

all: main.o
\tgcc -o a.out main.o

main.o:
\tgcc -c main.c

clean:
\trm *.o

};

textFile "main.c", <<END
#include <stdio.h>

int main(int argc, char* argv[]) {

\tprintf("\\n\\n");
\treturn 0;
};

END

} elsif ($type == 2) {
  ##########################################
  #
  #                 C++
  #
  ##########################################
textFile "test.sh", qq{
make all clean
./a.out command line args here
};
textFile "Makefile", qq{
all: main.o
\tg++ -o a.out main.o

main.o:
\tg++ -c main.cpp

clean:
\trm *.o

};

textFile "main.cpp", <<END
#include <iostream>
using namespace std;

int main(int argc, char* argv[]) {

\tstd::cout << "\\n\\n";
\treturn 0;
};
END
} elsif ($type == 3) {
  ##########################################
  #
  #                 Ruby
  #
  ##########################################
  my ($packageName, $uPackageName);
  $packageName = ($ARGV[1]) ? $ARGV[1] : "common";
  $packageName =~ s/[^a-z]//g;
  ($uPackageName = $packageName) =~ s/(\w+)/\u$1/;

textFile "$packageName.rb", <<END
module $uPackageName
  def debug(*args)
    puts args.inspect
  end
end

class File
  def to_a
    result = []
    each do |line|
      result.push( line.sub(/\\s+\$/,"") )
    end
    result
  end
end

if __FILE__ == \$0
  # testing purposes
end
END
;

textFile "main.rb", <<END
#!/usr/bin/ruby
\$: << "."
require '$packageName'

# script starts here

exit
END
;

} elsif ($type == 4) {
  ##########################################
  #
  #                 Perl
  #
  ##########################################
  my $packageName = ($ARGV[1]) ? $ARGV[1] : "common";
  $packageName =~ s/[^a-z]//g;

textFile "$packageName.pm", <<END
#!/usr/bin/perl
use strict;
use warnings;

package $packageName;

use Exporter;
our \@ISA = qw(Exporter);
our \@EXPORT = qw(
  debug
  textFile
);

use Data::Dumper;

sub debug {
  print Dumper(\$_[0]), "\\n";
}

sub textFile {
	my \$filename = shift;     # string
	my \$text = shift;         # array ref
	open FILE, ">\$filename" or die \$!;
	if (ref(\$text) eq 'ARRAY') {
		foreach my \$line (\@\$text) {
			print FILE \$line;
			print FILE "\\n";
    }
  } else {
  	print FILE \$text;
  }
  close FILE;
}

1;
END
;

textFile "main.pl", <<END
#!/usr/bin/perl
use strict;
use warnings;
use $packageName;

# script starts here

exit;
END
;

} else {
  # future setups
}

exit;
