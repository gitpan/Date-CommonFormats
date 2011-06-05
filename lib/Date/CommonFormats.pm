package Date::CommonFormats;

use strict;
use warnings;
require Exporter;
use Date::Format;
use Date::Parse;
use Date::Calc qw (Month_to_Text English_Ordinal Day_of_Week Day_of_Week_to_Text);

=head1 NAME

Date::CommonFormats - Common date formats made simple.

=head1 VERSION

Version 0.02

=cut

our $VERSION = '0.02';

=head1 SYNOPSIS

Date::CommonFormats provides a super simple interface for formatting
very common types of dates used on web pages and in RSS feeds.

	use Date::CommonFormats qw(:all);

	print format_date_w3c($timestamp);
	print format_date_rss($datetime);
	print format_date_usenglish_long_ampm($datetime);

Most of these functions expect as input a date or datetime value in 
the standard mysql format such as 2011-01-02 or 2011-02-02 01:02:03.

=head1 EXPORT

You can import all functions, however none are imported by default. 
use Date::CommonFormats qw(:all);
Importing all functions should be safe as the names are quite unique.

=cut

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
@ISA = qw(Exporter);
@EXPORT = qw();
@EXPORT_OK = qw
(
	format_date_integer
	format_date_rss
	format_date_usenglish
	format_date_usenglish_long_ampm
	format_date_cms_publishdate
	format_date_w3c
	);
%EXPORT_TAGS = ('all' => [@EXPORT_OK]);

=head1 SUBROUTINES

=head2 format_date_integer

Use this function for reducing a date or datetime to an integer useful 
in comparisons.

if (format_date_integer($date1) > format_date_integer($date2)) {

	...
}

=cut

#"%Y%m%d%H%M%S"
### this one shouldn't require any external module, mysql dates should convert happily to comparable number
### make sure you provide datetime or timestamp, not just date or your comparisons won't work right
sub format_date_integer {
	my $datetime = shift;
	return "" if !$datetime || $datetime eq "0000-00-00 00:00:00" || $datetime eq "0000-00-00";
	my ($date, $time) = split(" ", $datetime);	
	my @datevals = split("-", $date);
	my @timevals = split(":", $time);
	my $retval = join("", @datevals) . join("", @timevals);
	return $retval;
}

=head2 format_date_rss

Use this for formatting dates in the proper format for an RSS feed.

my $rss_formatted_date = format_date_rss($date);

=cut

#"%a, %e %B %Y %T %Z"
#Tue, 12 January 2010 09:11:32 PST
#Tue, 03 Jun 2003 09:39:21 GMT
sub format_date_rss {
	my $datetime = shift;
	return "" if !$datetime || $datetime eq "0000-00-00 00:00:00" || $datetime eq "0000-00-00";
	my ($date, $time) = split(" ", $datetime);	
	my ($year, $month, $day) = split("-", $date);
	my ($hour, $minute, $second) = split(":", $time);
	my $timezone = time2str("%Z", str2time($datetime));
	my @datevals = (Day_of_Week_to_Text(Day_of_Week($year,$month,$day)), $day, Month_to_Text($month), $year,$hour,$minute,$second, $timezone);
	my $retval = sprintf("%.3s, %02d %s %d %02d:%02d:%02d %s", @datevals);
	return $retval;
}

=head2 format_date_usenglish

Use this for formatting dates in US English similar to what you would 
see in a US newspaper or blog entry.

my $formatted_date = format_date_usenglish($date);

=cut

#Dec 22nd, 1956
## this one can accept mysql date or mysql datetime or mysql timestamp
sub format_date_usenglish {
	my $datetime = shift;
	return "" if !$datetime || $datetime eq "0000-00-00 00:00:00" || $datetime eq "0000-00-00";
	my ($date, $time) = split(" ", $datetime);	
	my ($year, $month, $day) = split("-", $date);
	my $string = sprintf("%.3s %s, %d",
		Month_to_Text($month),
		English_Ordinal($day),
		$year
	);
	return $string;
}

=head2 format_date_usenglish_long_ampm

Use this for formatting dates in US English similar to what you would 
see in a US newspaper or blog entry. This is the same as usenglish 
except it includes the time in AM/PM format.

my $formatted_date = format_date_usenglish_long_ampm($date);

=cut

#Dec 22nd, 1956 09:23 PM
sub format_date_usenglish_long_ampm {
	my $datetime = shift;
	return "" if !$datetime || $datetime eq "0000-00-00 00:00:00" || $datetime eq "0000-00-00";
	my ($date, $time) = split(" ", $datetime);	
	my ($year, $month, $day) = split("-", $date);
	my ($hour, $minute, $second) = split(":", $time);
	my $ampm = 'AM';
	if ($hour >= 12) {
		$hour -= 12;
		$ampm = 'PM';
	}
	$hour = 12 unless $hour;
	my $string = sprintf("%.3s %s, %d %02d:%02d %s",
		Month_to_Text($month),
		English_Ordinal($day),
		$year,
		$hour, $minute,
		$ampm
	);
	return $string;
}

=head2 format_date_cms_publishdate

Use this for formatting dates in short 24 hour format which is 
useful in a CRUD list screen where you need to see and sort by 
datetime but need to conserve space on the page by keeping your 
columns narrow.

my $formatted_date = format_date_cms_publishdate($date);

=cut

#Dec 22nd, 1956 09:23 PM
sub format_date_cms_publishdate {
	my $datetime = shift;
	return "" if !$datetime || $datetime eq "0000-00-00 00:00:00" || $datetime eq "0000-00-00";
	my ($date, $time) = split(" ", $datetime);	
	my ($year, $month, $day) = split("-", $date);
	my ($hour, $minute, $second) = split(":", $time);
	my $ampm = 'AM';
	if ($hour >= 12) {
		$hour -= 12;
		$ampm = 'PM';
	}
	$hour = 12 unless $hour;
	my $string = sprintf("%02d-%02d-%d %02d:%02d %s",
		$month,
		$day,
		$year,
		$hour, $minute,
		$ampm
	);
	return $string;
}

=head2 format_date_w3c

Use this for formatting dates in the W3C accepted format as 
described by ISO 8601. This can be useful for certain XML 
applications.

my $formatted_date = format_date_w3c($date);

=cut

## ISO 8601
## $date = sprintf("%d-%02d-%02d %02d:%02d:%02d", @date);

sub format_date_w3c {
	my $datetime = shift;
	return "" if !$datetime || $datetime eq "0000-00-00 00:00:00" || $datetime eq "0000-00-00";
	my ($date, $time) = split(" ", $datetime);
	my ($year, $month, $day) = split("-", $date);
	my ($hour, $minute, $second) = split(":", $time);
	my $timezone = time2str("%z", str2time($datetime));
	my $tz_firstpart = substr $timezone,0,3;
	my $tz_secondpart = substr $timezone,3,2;
	my $tz_finalstring = $tz_firstpart . ":" . $tz_secondpart;
	my @datevals = ($year,$month,$day,"T",$hour,$minute,$second, $tz_finalstring);
	my $retval = sprintf("%d-%02d-%02d%s%02d:%02d:%02d%s", @datevals);
	return $retval;
}


=head1 AUTHOR

Chris Fulton, C<< <chris at masonqm.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-date-commonformats at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Date-CommonFormats>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Date::CommonFormats


You can also look for information at:

=over 4

=item * GITHUB

L<https://github.com/masonqm/Date-CommonFormats>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Date-CommonFormats>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Date-CommonFormats>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Date-CommonFormats>

=item * Search CPAN

L<http://search.cpan.org/dist/Date-CommonFormats/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2011 Chris Fulton.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of Date::CommonFormats
