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
  5 => "Python",
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

  # create directory
  `mkdir lib`;
  `touch input.txt`; # sample file

  # simple file utility
textFile "./lib/file_util.rb", <<END
class File
  def to_a
    result = []
    each do |line|
      result.push( line.sub(/\\s+\$/,"") )
    end
    result
  end
end
END
;

textFile "$packageName.rb", <<END
require "./lib/file_util"

module $uPackageName
  def debug(*args)
    puts args.inspect
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
fn = (ARGV[0]) ? ARGV[0] : "input.txt"
f = File.new( fn ).to_a
puts f.inspect

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
  lineArray
  trim
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

sub trim {
	my \$result = shift;
	\$result =~ s/^\\s//;
	\$result =~ s/\\s+\$//;
	return \$result;
}

sub lineArray {
  my \$fileName = shift;
  open FILE, "\$fileName" or die \$!;
  my \@lines = <FILE>;
  \@lines = map { trim(\$_) } \@lines;
  return \\\@lines;
}

1;
END
;
  # extra file
  `touch input.txt`;

textFile "main.pl", <<END
#!/usr/bin/perl
use strict;
use warnings;
use $packageName;

# script starts here
my \$fileName = (\$ARGV[0]) ? \$ARGV[0] : "input.txt";
my \$lines = lineArray "\$fileName";
debug \$lines;

exit;
END
;

} elsif ($type == 5) {
  ##########################################
  #
  #                 Python
  #
  ##########################################
  my ($packageName, $uPackageName);
  $packageName = ($ARGV[1]) ? $ARGV[1] : "common";
  $packageName =~ s/[^a-z]//g;
  ($uPackageName = $packageName) =~ s/(\w+)/\u$1/;

textFile "main.py", <<END
#!/usr/bin/python
import sys
sys.path.append("./$packageName")
#import util
#from node import Node
from util import *
from node import *

#util.f1( 1, 'chester', {} )
f1( 1, 'chester', {} )
f2()

n = Node("The Guy")
n.debug()

m = Nyde()
m.debug()

END
;
  
  # create the directory
  `mkdir $packageName`;

textFile "$packageName/util.py", <<END
__all__ = ["f1","f2"]

# sample function
def f1( n, s, o ):
  print "hello, world!"

def f2():
  print "hello, wordly!"

END
;

textFile "$packageName/node.py", <<END
__all__ = ["Node","Nyde"]

class Nyde:
  def __init__(self):
    self.confused = True
  def debug(self):
    print "debugging nyde"

class Node:
  """
  Sample Linked List Node class
  """
  def __init__(self, name="chester"):
    self.name = name
    self.adj = []
    self.next = None
    self.prev = None
    self.data = {}

  # always gets self
  def debug(self):
    print "debugging node"

END
;

} else {
  # future setups
}

exit;
