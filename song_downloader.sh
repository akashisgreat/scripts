#/bin/bash

## USAGE:
  # song_downloader 2023

year=$1;
category="bollywood-mp3-songs"
audio_quality="320 KBPS"
downloader="aria2c -d $year"

mkdir -p $year



baseurl="https://pagalnew.com"
categoryurl="$baseurl/category/$category";


function get_pages {
  current_page=1
  last_page=$(curl -s $1/$current_page/$2 | pup 'div.pagination' | pup 'a attr{href}' | tail -1 | rev | cut -d'/' -f2 | rev); # $1 $2= $url $year

  if ! expr "$last_page" + 0 > /dev/null 2>&1; then
    last_page=1;
  fi
  
  while [ $current_page -le $last_page ];
  do
    get_album "$1/$current_page/$2"
    current_page=$(( $current_page + 1 ))
  done
}

function get_album {
  album_urls=$(curl -s $1 | grep -o "$baseurl/album/.*" | cut -d\" -f1); # $1 = $get_pages

  for album_url in $album_urls;
  do
    get_song $album_url 
  done
}


function get_song {
  song_pages=$(curl -s $1 | grep -oiE "$baseurl/songs/.*" | cut -d\" -f1); # $1 = $album_urls
  for song_page in $song_pages;
  do
        download_song $song_page;
  done
}

function download_song {
  song_url=$(curl -s $1 | grep "$audio_quality Song Download" | cut -d\" -f8); # $1 = $song_pages
  echo "Downloading: $baseurl$song_url";
  $downloader "$baseurl$song_url";
}

## Usage:
# get_pages $baseurl $year
# get_album "https://pagalnew.com/category/bollywood-mp3-songs/1/2023"
# get_song "https://pagalnew.com/songs/pyaar-hona-na-tha-jubin-nautiyal.html"

## To get very latest song:
#get_song $baseurl

## Main Usage:
get_pages $categoryurl $year
