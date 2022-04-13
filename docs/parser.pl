#!/usr/bin/env perl

use constant DIR => q{_posts};
use constant CONTENT_DIR => q{content};
use constant DATA_DIR => q{_data};

&main_misc_videos;

exit (0);

sub main_misc_videos {
    my $files = get_files(DIR);
    my $lesson = 1;
    my $outfile = sprintf q{%s/misc_videos.yml}, DATA_DIR;

    open my $out, ">$outfile"  or qq{Cannot open $outfile: $1};
    foreach (sort @$files) {
        print "$_\n";
        printf $out qq{lesson-%d: [ '%s' ]\n},
          $lesson++, join "','", parse_misc_videos($_);
    }
    close $out;
}

sub parse_misc_videos {
    my $file    = $_[0];
    my $infile  = DIR . '/' . $file;
    my @ytids   = ();

    open my $fh, $infile or qq{Cannot open $infile: $!};

    while (<$fh>) {
      next unless /include video\.html id='([^\']+)'/;
      push @ytids, $1;
    }

    close $fh;
    return @ytids;
}

sub main_viet {
  my $files   = get_files(DIR);
  my $lesson  =
  my $week    = 0;

  foreach (sort @$files) {
    $week++ if (++$lesson % 5 == 1);
    my $dir = sprintf q{_week-%02d}, $week;
    create_dialog_viet($dir, $lesson, $_);
  }
}

sub create_dialog_viet {
  my $dir     = $_[0];
  my $lesson  = $_[1];
  my $file    = DIR . '/' . $_[2];
  my $outfile = CONTENT_DIR . "/$dir/viet-$lesson.md";
  my $begin   = 0;
  my $head    = 0;
  my $index   = 1;

  print "$file -> $outfile\n";

  open my $fh, $file or qq{Cannot open $file: $!\n};
  open my $out, ">$outfile" or qq{Cannot open $outfile: $!\n};

  while (<$fh>) {
    if (/^-+$/ && !$head) {
      print $out $_;
      $head = 1;
      next;
    } if (/^-+$/ && $head) {
      print $out "$_\n";
      $head = 0;
      next;
    } elsif ($head) {
      s/: post/: translation\nlang: viet/;
      print $out $_;
      next;
    }

    /^---: / && $begin++ && next;
    next if $begin != 2;
    last if (/^\s*$/);
    chomp;

    my ($who,$sentence) = (split q{ | }, $_, 3)[0,2];
    $sentence =~ s/'/&rsquo;/g;

    printf $out
      "{%% include lesson/bubble.html text='%s' side='%s' index=%d %%}\n",
      $sentence,
      ($who eq 'Nam' ? 'right' : 'left'),
      $index++;
  }
  close $fh;
  close $out;
}


sub main_english {
  my $files   = get_files(DIR);
  my $lesson  =
  my $week    = 0;

  foreach (sort @$files) {
    $week++ if (++$lesson % 5 == 1);
    my $dir = sprintf q{_week-%02d}, $week;
    create_dialog($dir, $lesson, $_);
  }
}

sub create_dialog {
  my $dir     = $_[0];
  my $lesson  = $_[1];
  my $file    = DIR . '/' . $_[2];
  my $outfile = CONTENT_DIR . "/$dir/lesson-$lesson.md";
  my $begin   = 0;
  my $head    = 0;
  my $index   = 1;

  print "$file -> $outfile\n";

  open my $fh, $file or qq{Cannot open $file: $!\n};
  open my $out, ">$outfile" or qq{Cannot open $outfile: $!\n};

  while (<$fh>) {
    if (/^-+$/ && !$head) {
      print $out $_;
      $head = 1;
      next;
    } if (/^-+$/ && $head) {
      print $out "$_\n";
      $head = 0;
      next;
    } elsif ($head) {
      s/: post/: lesson/;
      print $out $_;
      next;
    }

    next if !$begin && !/^---: /;

    if (!$begin) {
      $begin = 1;
      next;
    }
    last if (/^\s*$/);
    chomp;

    my ($who,$sentence) = (split q{ | }, $_, 3)[0,2];
    $sentence =~ s/\{[^']+"([^"]+)"[^\}]+\}/\^$1/g;
    $sentence =~ s/\{[^']+'([^']+)'[^\}]+\}/\^$1/g;
    $sentence =~ s/'/&rsquo;/g;

    printf $out
      "{%% include lesson/bubble.html text='%s' side='%s' index=%d %%}\n",
      $sentence,
      ($who eq 'Man' ? 'right' : 'left'),
      $index++;
  }
  close $fh;
  close $out;
}

sub main_clips {
    my $files = get_files(DIR);
    my $lesson = 1;
    my $outfile = sprintf q{%s/clips.yml}, DATA_DIR;
    open my $out, ">$outfile"  or qq{Cannot open $outfile: $1};
    foreach (sort @$files) {
        print "$_\n";
        printf $out qq{lesson-%d: [ %s ]\n}, $lesson++, join ',', parse($_);
    }
    close $out;
}

sub parse_clips {
    my $file    = $_[0];
    my $infile  = DIR . '/' . $file;
    my @coords  = ();

    open my $fh, $infile or qq{Cannot open $infile: $!};

    while (<$fh>) {
      next unless /include youtube\.html start=(\d+) end=(\d+)/;
      @coords = ( $1, $2 );
      last;
    }

    close $fh;
    return @coords;
}


sub get_files {
    my $path    = shift;
    opendir my $dir, $path or die "Can't open directory $path: $!\n";
    my @files = grep /\.md$/, readdir($dir);
    closedir $dir;
    return \@files;
}
