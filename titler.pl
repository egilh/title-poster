#!/etc/perl
# Fetches titles
use strict;
use Irssi;
use vars qw($VERSION %IRSSI);

$VERSION = '001';
%IRSSI = (
    authors     => 'gaLezki',
    contact     => 'galezkiatgmail.com',
    name        => 'titler',
    description => 'Fetches titles',
    license     => 'GNU General Public License 3.0' );


my $chan = "#channel";
my $apikey = "APIKEY";
my $titleline;
my $titlestart;
my $titleend;
my $word;
my $url;
my $urlfound = 0;
my $title;
my $ytapiurl = "https://www.googleapis.com/youtube/v3/videos?part=id%2Csnippet&key=$apikey&id=";
my $ytid; # video id to fetch from youtube api
my @denied_titles = ("Streamable - simple", "hockey - Jiffier gifs through HTML5 Video Conversion.",
					"Untitled - Gfycat");


sub get_title {
    my ($server,$msg,$target, $channel, $chatnet) = @_;

    $_ = $msg;
    if ($chatnet eq $chan) {
        if (/^*.www.youtube.com.*$/ or /^*.youtu.be.*$/) {
			my @splitline = split(' ',$_);
			foreach $word (@splitline) {
				if (index($word, "http") != -1) {
					$urlfound = 1;
					$url = $word;
					last;
				}
			}


			if ($urlfound eq 1) {
				if (/^*.www.youtube.com.*$/) {
					my @urlarray = split("v=", $url);
					if (index($urlarray[1], "&") != -1) {
						my @idarray = split("\\&", $urlarray[1]);
						$ytid = $idarray[0];
					} else {
						$ytid = $urlarray[1];
					}
				} elsif (/^*.youtu.be.*$/) {
					my @urlarray = split("youtu.be/", $url);
					if (index($urlarray[1], "?") != -1) {
						my @idarray = split("\\?", $urlarray[1]);
						$ytid = $idarray[0];
					} else {
						$ytid = $urlarray[1];
					}
				}

				$titleline = `wget -q -O- '$ytapiurl$ytid' | grep -m 1 'title'`;
				my $titlestart = index($titleline, '"title":');
				my $title = substr $titleline, $titlestart + 10, -3;
				if ($title ne "") {
					$server->command("msg $chan Title: $title");
				}
				$urlfound = 0;
			}

		} elsif (/^*.imgur.com.*$/ or /^*.streamable.com.*$/ or /^*.www.iltalehti.fi.*$/ or /^*.www.iltasanomat.fi.*$/ or /^*.gfycat.com.*$/ or /^*.*.*$/) {
			my @splitline = split(' ',$_);
			foreach $word (@splitline) {
				if (index($word, "http") != -1) {
					$urlfound = 1;
					$url = $word;
					if (/^*.www.iltalehti.fi.*$/ or /^*.www.iltasanomat.fi.*$/) {
						$url =~ s/www/m/g;
					}
					last;
				}
			}
			if ($urlfound eq 1) {

				if (/^*.imgur.com.*$/) {
					$titleline = `wget -q -O- '$url' | grep -m 1 '<meta property="og:title" content='`;
					$titlestart = index($titleline, "content=");
					$titleend = index($titleline, "/>");
					$title = substr $titleline, $titlestart + 9, -4;

        }
        elsif (/^*.*.*$/) {
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
					$server->command("msg $chan Title: $title");
				}
				$urlfound = 0;
			}

		}

    }

}



Irssi::signal_add('message public','get_title');
