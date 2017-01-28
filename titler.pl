#!/etc/perl
# Fetches titles
use strict;
use Irssi;
use vars qw($VERSION %IRSSI);
require HTML::HeadParser;

$VERSION = '0.1';
%IRSSI   = (
    authors     => 'egilh, Monk',
    name        => 'title-poster',
    description => 'Fetches and posts titles',
    license     => 'GNU General Public License 3.0'
);

my $chan = '#channel';
my $useragent = 'Mozilla';
my ($url, $word, $title, $html, $a, $p) = "";;
my @urls = ();
my $urlfound = 0;
my $sameurl = 0;
my @denied_titles = ();

sub get_title {
    my ( $server, $msg, $target, $channel, $chatnet ) = @_;

    $_ = $msg;
    if ( $chatnet eq $chan ) {
        if ( $_ =~ /(https?\:\/\/[\.a-zA-Z0-9\/+:\?\=\&\w_-]{0,500})/gi ) {
            my @splitline = split( /\s/, $_ );
            foreach $word (@splitline) {
                if ( index( $word, 'http' ) != -1 ) {
                    $urlfound = 1;
                    $url = $word;
                    $p    = HTML::HeadParser->new;
                    $html = (
                    `curl -L -s --compressed --max-filesize 1000000 -H 'Accept-Language: nb-no, en-us' -A $useragent $url`
#`wget -U $useragent --header='Accept-Charset: utf-8' --header='Accept-Language: nb-no, en-us' -q -O- $url`
                    );
                    $p->parse($html);
                    $title = $p->header('Title');
                    $title = substr( $title, 0, 250 );
                    foreach my $d_title (@denied_titles) {
                        if ( index( $title, $d_title ) ne -1 ) {
                            return;
                        }
                    }
                    if ( $title ne '' ) {
                        $server->command("msg $chan $title");
                    }
                    $urlfound = 0;
                    #$sameurl = 0;
                }
            }
        }
    }
}
Irssi::signal_add( 'message public', 'get_title' );
