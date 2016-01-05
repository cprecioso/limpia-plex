path = require "path"
shell = require "shelljs"; shell.config.silent = yes
program = require "commander"
pkginfo = require "./package.json"
trash = require "trash"
require "colors"

Promise::tap = (f) -> @.then (v) -> do (v) -> Promise.resolve(f v).then (-> v), (-> v)

exports.run = (argv) ->
	{parse, assess, inform, confirm, remove} = exports
	Promise.resolve argv
	.then parse
	.then assess
	.tap (v) ->
		inform v
		.then confirm
		.then (apply) -> process.exit() if not apply
	.then remove
	.then ->
			console.log "Success!".green
			process.exit 0
		, (e) ->
			console.error "Error!".red
			console.error e if e
			process.exit 1

exports.parse = (argv) -> new Promise (fulfill, reject) ->
	program._name = pkginfo.name
	{args, extensions, verbose, debug, list} = program
		.version pkginfo.version
		.description pkginfo.description
		.arguments "<dirs...>"
		.option "-v, --verbose",
			"enable verbose mode"
		.option "-d, --debug",
			"enable debug mode"
		.option "-e, --extensions [exts]",
			"list of additional extensions to consider as video",
			((exts) -> exts.trim().split(","))
		.option "-l, --list",
			"lists currently supported extensions"
		.parse argv
	
	args =
		dirs: args
		exts: require("./extensions.json")
		verbose: !!verbose
		debug: !!debug
		list: !!list
	
	args.exts.concat extensions if extensions?.length > 0
	
	if args.list
		for ext in args.exts
			console.log ext
		process.exit()
	
	if args.dirs.length is 0
		program.outputHelp()
		reject "Please specify the Plex library folder(s)"
	
	fulfill args

exports.assess = (opts) -> new Promise (fulfill) ->
	{dirs, exts} = opts
	data = {}
	for rootFolder in dirs
		rootFolder = path.resolve rootFolder
		lsResult = shell.ls rootFolder
		throw error if error = shell.error()
		data[path.basename rootFolder] = for folder in lsResult
			folder = path.resolve rootFolder, folder
			[keep, reason] = do ->
				ls2Result = shell.ls "-R", folder
				throw error if error = shell.error()
				for file in ls2Result
					lfile = file.toLowerCase()
					extension = path.extname(lfile)[1...]
					if lfile.includes("sample")
						continue
					if extension in exts
						return [true, path.basename file]
				return [no]
			[folder, !!keep, reason]
	fulfill [opts, data]

exports.inform = ([opts, report]) -> new Promise (fulfill) ->
	actionNeeded = false
	{verbose, debug} = opts
	for library, contents of report
		console.log "--- Processing ".blue + library.bold + " ---".blue
		for [folder, keep, reason] in contents
			console.log (if keep then "Keep".green else (actionNeeded = true; "Remove".red)), "\t", path.basename(folder).bold
			console.log "\t -> Found", reason.bold if reason and verbose and not debug
	
	if debug and actionNeeded
		files = ""
		for _, results of report then for [folder, keep, reason] in results when not keep
			files += folder + "\n"
			files += "-> #{reason}\n" if reason and verbose
		console.log "\n-- START DEBUG INFO --\n#{files}--  END DEBUG INFO  --".bgYellow.black
	
	return fulfill actionNeeded

exports.confirm = (actionNeeded) -> new Promise (fulfill) ->
	return fulfill no if not actionNeeded
	process.stdout.write "\n" + "Apply?".bgRed.white + " (Y/n) "
	process.stdin
		.setEncoding "utf8"
		.once "data", (r) ->
			fulfill switch r.trim().toLowerCase()
				when "", "y", "yes" then yes
				when "", "n", "no" then no
				else exports.confirm()

exports.remove = ([opts, report]) ->
	files = []
	files.push(folder) for [folder, keep] in results when not keep for _, results of report
	trash files
