#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;

# Default SNP delimiter
my $snp_delim = "_";

# Parse command-line options
GetOptions("snp_delim=s" => \$snp_delim) or die "Usage: $0 --snp_delim <delimiter> <inputfile>\n";

# Check for input file argument
my $inputfile = shift @ARGV or die "Error: No input file provided.\n";

# Open the input file
open(my $fh, "<", $inputfile) or die "Cannot open file: $inputfile\n";

# Function to format chromosome names while preserving suffixes
sub format_chrom {
    my ($chrom) = @_;

    # If already formatted as "ChrXX", return as-is
    if ($chrom =~ /^Chr\d+/) {
        return $chrom;
    }

    # Extract numeric part and suffix
    if ($chrom =~ /^(\d+)([A-Za-z]*)$/) {
        my $num = sprintf("Chr%02d", $1);  # Convert to Chr01, Chr02, etc.
        return $num . $2;  # Append suffix if present
    }

    return $chrom;  # Return unchanged for other cases
}

# Process each line in the file
while (my $line = <$fh>) {
    chomp $line;
    my @info = split("\t", $line);
    my $snp = $info[0];

    # Handle additional information (if exists)
    my $additional_info = (scalar @info > 1) ? join(",", @info[1..$#info]) : ".";

    # Split SNP identifier into chromosome and position
    my ($chrom, $position) = split(/$snp_delim/, $snp);

    # Format chromosome correctly
    $chrom = format_chrom($chrom);

    # Compute start and end positions
    my $start = $position - 1;
    my $end = $position;

    # Print formatted output
    print "$chrom\t$start\t$end\t$additional_info\n";
}

# Close file handle
close($fh);
