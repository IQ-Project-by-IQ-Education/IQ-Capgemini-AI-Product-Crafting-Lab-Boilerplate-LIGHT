# Optional local server for the LIGHT app - Perl, built-in modules only (no install).
# Serves the project folder on http://localhost:<port>/ to THIS computer only (loopback).
#   perl tools/serve.pl 8080
# Normally started by tools/launch.sh or tools/launch.ps1, not by hand.
use strict;
use warnings;
use IO::Socket::INET;
use FindBin;
use Cwd qw(abs_path);

my $port = $ARGV[0] || 8080;
(my $root = abs_path("$FindBin::Bin/..")) =~ s{\\}{/}g;
my %types = (
  html => 'text/html; charset=utf-8', js => 'text/javascript; charset=utf-8', css => 'text/css; charset=utf-8',
  json => 'application/json', csv => 'text/csv; charset=utf-8', txt => 'text/plain; charset=utf-8',
  png => 'image/png', jpg => 'image/jpeg', jpeg => 'image/jpeg', gif => 'image/gif', svg => 'image/svg+xml',
  ico => 'image/x-icon', webp => 'image/webp', mp4 => 'video/mp4', woff => 'font/woff', woff2 => 'font/woff2',
  sqlite => 'application/x-sqlite3',
);

my $server = IO::Socket::INET->new(LocalAddr => '127.0.0.1', LocalPort => $port, Listen => 20, ReuseAddr => 1)
  or do { print "PORT BUSY: $port\n"; exit 2 };
$| = 1;
print "SERVING http://localhost:$port/\n";

sub reply {
  my ($c, $code, $type, $body) = @_;
  print $c "HTTP/1.1 $code\r\nContent-Type: $type\r\nContent-Length: " . length($body)
    . "\r\nCache-Control: no-store\r\nConnection: close\r\n\r\n" . $body;
}

while (my $c = $server->accept) {
  eval {
    binmode $c;
    $c->timeout(5);
    my $line = <$c> // '';
    while (my $h = <$c>) { last if $h =~ /^\r?\n$/ }
    my (undef, $path) = split / /, $line;
    $path //= '/';
    $path =~ s/[?#].*//;
    $path =~ s/%([0-9A-Fa-f]{2})/chr(hex $1)/ge;
    $path = '/index.html' if $path eq '/';
    if ($path eq '/favicon.ico') { reply($c, '204 No Content', 'text/plain', ''); die "done\n" }
    my $file = abs_path("$root$path");
    $file =~ s{\\}{/}g if defined $file;
    if (!defined $file || index(lc $file, lc "$root/") != 0 || !-f $file) {
      reply($c, '404 Not Found', 'text/plain', 'Not found');
    } else {
      my ($ext) = $file =~ /\.([^.\/]+)$/;
      open my $fh, '<:raw', $file or die "read\n";
      local $/;
      my $body = <$fh>;
      close $fh;
      reply($c, '200 OK', $types{lc($ext // '')} // 'application/octet-stream', $body);
    }
  };
  close $c;
}
