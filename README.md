# limpia-plex 🎥 🔍 🗡
###Cleans folders with no video files in Plex libraries.
Ever erased something from the Plex interface? Did you realize the folder just kept sitting there, along with subtitle files or any other leftovers? Then this is for you!

This little tool crawls through your Plex library folder(s), finds every top-level folder with no video files and moves them to the trash.
It also keeps `torrent` and `part` files safe, just in case.

###[Features](#features) · [Installation](#installation) · [Usage](#usage) · [Example](#example)

## Features
- Crawls nested subfolders deep into the tree
- Detects `mp4`, `m4v`, `avi` and `mkv` for video files. Also `torrent` and `part` for the downloading folks.
- Skips those pesky "sample" folders.
- Supports custom extensions. Have a lot of video files in an obscure format? Well this is your day then, just write `limpia-plex -e mvf "My Library"` (*macarena video file*). Want it supported out-of-the-box? [Open an issue](https://github.com/cprecioso/limpia-plex/issues/new)
- **Moves to trash**, doesn't remove directly. The best if you have trust issues.
- Great, informative, colorful output.
- It actually has an API! Self-documentative, though 😁.
- Actually compatible with plain folder trees, no need for Plex, if you're that organized. Therefore, possibly compatible with XMBC or other media managers.
- Tested in Mac, should be compatible with Windows and Linux (and their trash folders).

## Installation
`npm install -g cprecioso/limpia-plex`

## Usage
```text
$ limpia-plex -h

  Usage: limpia-plex [options] <dirs...>

  Cleans folders with no video files in Plex libraries.

  Options:

    -h, --help               output usage information
    -V, --version            output the version number
    -v, --verbose            enable verbose mode
    -d, --debug              enable debug mode
    -e, --extensions [exts]  list of additional extensions to consider as video
    -l, --list               lists currently supported extensions
```



## Example
My Plex Library is, surprisingly, at `~/Movies/Plex Library`. There, I have some movies I've downloaded from BitTorrent. I've already seen *Sintel*, but when I erased it to save space in my laptop, the subtitle file was left over. We're going to remove that folder, leaving alone the movies I've still haven't seen (*Big Buck Bunny*) and the ones still downloading (*Tears of Steel*).

```text
$ cd ~/Movies
$ tree "Plex Library"
Plex\ Library
├── Big\ Buck\ Bunny
│   ├── Big\ Buck\ Bunny.en.srt
│   ├── Big\ Buck\ Bunny.es.srt
│   └── Big\ Buck\ Bunny.mp4
├── Sintel
│   └── Sintel.en.srt
└── Tears\ of\ Steel
    └── Tears\ of\ Steel.mp4.part

3 directories, 5 files
$ limpia-plex "Plex Library"
--- Processing Plex Library ---
Keep 	 Big Buck Bunny
Remove 	 Sintel
Keep 	 Tears of Steel

Apply? (Y/n) Y
Success!
$ tree "Plex Library"
Plex\ Library
├── Big\ Buck\ Bunny
│   ├── Big\ Buck\ Bunny.en.srt
│   ├── Big\ Buck\ Bunny.es.srt
│   └── Big\ Buck\ Bunny.mp4
└── Tears\ of\ Steel
    └── Tears\ of\ Steel.mp4.part

2 directories, 4 files
```

**_Et voilà!_** Everything is left just as I wanted.
