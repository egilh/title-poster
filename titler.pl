#!/etc/perl
# Fetches titles
use strict;
use Irssi;
use vars qw($VERSION %IRSSI);

$VERSION = '0.1';
%IRSSI = (
    authors     => 'egilh, Monk',
    name        => 'title-poster',
    description => 'Fetches and posts titles',
    license     => 'GNU General Public License 3.0' );


my $chan = "#channel";
my $titleline;
my $titlestart;
my $titleend;
my $word;
my $url;
my $urlfound = 0;
my $title;
my @denied_titles = ("Streamable - simple", "Jiffier gifs through HTML5 Video Conversion.",
					"Untitled - Gfycat");


sub get_title {
    my ($server,$msg,$target, $channel, $chatnet) = @_;

    $_ = $msg;
    if ($chatnet eq $chan) {
      if (/^http.*.*$/ or /^https.*.*$/) {
        my @splitline = split(' ',$_);
        foreach $word (@splitline) {
			if (index($word, "http") != -1) {
					$urlfound = 1;
					$url = $word;
					last;
				}
			}
			if ($urlfound eq 1) {
			my @splitline = split(' ',$_);
			foreach $word (@splitline) {
				if (index($word, "http") != -1) {
					$urlfound = 1;
					$url = $word;
					last;
				}
			}
				if (/^*.*.*$/) {
          $titleline = `wget -q -O- '$url' | awk '/<title>([^<]*)<\/title>/'`;
          $titlestart = index($titleline, "<title>");
          $titleend = index($titleline, "<title/>");
          $title = substr $titleline, $titlestart + 7, -8;
				}
				foreach my $d_title (@denied_titles) {
					if (index($title, $d_title) ne -1) {
						return;
					}
				}

			if ($title ne "") {
					$server->command("msg $chan $title");
				}
				$urlfound = 0;
			}

		}
}
}
Irssi::signal_add('message public','get_title');
