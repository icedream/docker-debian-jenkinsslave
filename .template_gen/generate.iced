String::endsWith = (suffix) -> this.indexOf(suffix, this.length - suffix.length) != -1

fs = require "fs"
request = require "request"
path = require "path"
merge = require "merge"
swig = require "swig"
mkdirp = require "mkdirp"
# childproc = require "child_process"
# exec = childproc.spawnSync

## BEGIN OF CONFIGURATION ##
architectures =
	amd64: "library/debian"
	i386: "icedream/debian-i386"
baseDir = path.resolve path.join(__dirname, "..")
templateDir = path.join baseDir, ".template"
maintainer = "Carl Kittelberger, it@icedreammusic.eu"
## END OF CONFIGURATION ##

compiledTemplates = {}

compileDir = (srcDir, targetDir, data) ->
	srcDir = srcDir + path.sep unless srcDir.endsWith path.sep
	targetDir = targetDir + path.sep unless targetDir.endsWith path.sep
	await fs.readdir srcDir, defer(err, files)
	if err
		throw new Error "Failed to read source directory: #{srcDir}"
	for file in files
		srcPath = path.join srcDir, file
		targetPath = path.join targetDir, file
		await fs.stat srcPath, defer(err, stat)
		if err
			console.error "Failed to stat, skipping: #{srcPath}"
			continue
		if stat.isDirectory()
			compileDir srcPath, targetDir
		else
			# check if this has been compiled before
			if srcPath not of compiledTemplates
				# we need to compile this first
				#console.log "Compiling: #{srcPath}"
				compiledTemplates[srcPath] = swig.compileFile srcPath

			fs.writeFile targetPath, compiledTemplates[srcPath] data, err

			if err
				console.error "Failed to write: #{targetPath}", err
				continue

			console.log "Written: #{targetPath}"

for own architecture, original_repository of architectures
	await request {
		url: "https://registry.hub.docker.com/v1/repositories/#{original_repository}/tags"
		json: true
	}, defer(error, response, tags)

	if error
		console.error "Failed to download tag list for #{original_repository}.", error
		continue

	if response.statusCode != 200
		console.error "Failed to download tag list for #{original_repository}, the server returned HTTP error code #{response.statusCode}."
		continue

	for tag in tags
		targetDir = path.join baseDir, "#{tag.name}-#{architecture}"
		await mkdirp targetDir, defer err
		if err
			console.error "Could not create directory", targetDir
			continue

		compileDir templateDir, targetDir,
			original_image: "#{original_repository}:#{tag.name}"
			original_repository: original_repository
			tag: tag
			architecture: architecture
			maintainer: maintainer
