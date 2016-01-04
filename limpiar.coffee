{join, extname, basename} = require "path"
{pwd, ls} = require "shelljs"
trash = require "trash"
require "colors"

currentDir = pwd()

# Parse arguments
args = process.argv[2..]
verbose = false
searchFor = []
requiredExtensions = ["mp4", "m4v", "mkv", "avi", "part", "torrent"]
for arg in args
	if arg[0] is "-"
		switch arg
			when "-v", "--verbose" then verbose = true
	else searchFor.push arg

searchFor = ["Películas", "Series"] if searchFor.length is 0

toRemove = []

for rootFolder in ls currentDir when rootFolder in searchFor
	rootFolder = join currentDir, rootFolder
	console.log "--- Processing ".blue + "#{basename(rootFolder)}".bold + " ---".blue
	for folder in ls rootFolder
		folder = join rootFolder, folder
		folderName = basename folder
		[keep, reason] = do ->
			for file in ls "-R", folder
				lfile = file.toLowerCase()
				extension = extname(lfile)[1...]
				if lfile.includes("sample")
					console.log "\t -> Skipped sample".reset, "#{file}".bold
					continue
				if extension in requiredExtensions
					return [true, basename file]
			return [no]
		
		reason = if reason then "\t -> Found".reset + " #{reason}".bold else ""
		if keep
			console.log "Keep\t".green, "#{folderName}".bold
			# console.log reason if reason
		else
			console.log "Remove\t".red, "#{folderName}".bold
			# console.log reason if reason
			toRemove.push folder

if toRemove.length is 0
	process.exit 0

process.stdout.write "Apply?".bgRed.white + " (Y/n) "
process.stdin
	.setEncoding "utf8"
	.once "data", (str) ->
		switch str.trim().toLowerCase()
			when "", "y", "yes"
				console.log "Applying..."
				trash toRemove
				.then ->
						console.log "Success!".green
						process.exit 0
					, (e) ->
						console.log "Error moving to trash!".red.bold
						console.log e if e
						process.exit 1
			else
				console.log "Not applied"
				process.exit 0
	.resume()
