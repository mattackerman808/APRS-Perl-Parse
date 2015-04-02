#!/usr/bin/perl -w

# matt@n6ack.com

# setup our includes
use strict;
use Ham::APRS::FAP qw(parseaprs);
use Data::Dumper;

# setup data dumper if needed
$Data::Dumper::Indent = 1;
$Data::Dumper::Sortkeys = 1;

# open pipe to log file
open my $pipe, "-|", "/usr/bin/tail", "-F", "-n 1" , "/var/log/aprx/aprx-rf.log"
	    or die "could not start tail on file.log: $!";

# never ending while loop
while (<$pipe>) {
	#split log entry in an array, space seperated
	my @chunks = split ' ', $_;
	#setup a temp array for formatting
	my @tmparray;
	#set a position counter
	my $ix = 4;
	#while loop to take index 4 and beyond, load into array
	while( $ix <= $#chunks ) {
		$tmparray[$ix-4] = $chunks[$ix];
    		$ix++;
		}
	# take tmp array and load into scalar space seperated
	my $aprspacket = join(' ',@tmparray);
	# setup packet data aray
	my %packetdata;
	# parse packet with function, load into array
	my $retval = parseaprs($aprspacket, \%packetdata);
	# if loop to output data
	if ($retval == 1) {
		# print STDOUT newline
		print STDOUT "\n";
		# this while loop print STDOUT out the data in array 
      		while (my ($key, $value) = each(%packetdata)) {
			# if loop for handling list of hashes in digipeater field
			if ($key =~ "digipeaters") {
				# setup reference for digipeaters list
				my $listref = $packetdata{"digipeaters"};
				print STDOUT "digipeaters: ";
				# loop through list reference based on keys 
				foreach my $listrefkey (keys $listref) {
					# grab hash reference from key value of list
					my $hashref = ${ $listref }[$listrefkey];
					# set digicall to hashref + call key
					my $digicall = ${ $hashref }{"call"};
					# print STDOUT out value
					print STDOUT "$digicall ";
				}
				# print STDOUT out new line after list of digi's
				print STDOUT "\n";	
			} else { # not a digipeater key, do default
				# print STDOUT of key : value of array
              			print STDOUT "$key: $value\n";
     			}
		}
	}
}
