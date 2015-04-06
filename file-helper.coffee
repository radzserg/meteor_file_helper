class FileHelper
  constructor: () ->

    # clear directory
  @rmDir: (dirPath, removeSelf = true) ->
    fs = Npm.require('fs')
    try
      files = fs.readdirSync(dirPath)
    catch e
      return

    if files.length > 0
      i = 0

      while i < files.length
        filePath = dirPath + "/" + files[i]
        if fs.statSync(filePath).isFile()
          fs.unlinkSync filePath
        else
          FileHelper.rmDir filePath
        i++
    fs.rmdirSync dirPath if removeSelf

  ## Copy directory recursively
  @cpDir: (source, target) ->
    fs = Npm.require('fs')
    path = Npm.require('path')

    files = []

    #check if folder needs to be created or integrated
    targetFolder = path.join(target, path.basename(source))
    fs.mkdirSync targetFolder  unless fs.existsSync(targetFolder)

    #copy
    if fs.lstatSync(source).isDirectory()
      files = fs.readdirSync(source)
      files.forEach (file) ->
        curSource = path.join(source, file)
        if fs.lstatSync(curSource).isDirectory()
          FileHelper.cpDir curSource, targetFolder
        else
          FileHelper.cpFile curSource, targetFolder

  ## Copy file
  @cpFile = (source, target) ->
    fs = Npm.require('fs')
    path = Npm.require('path')
    targetFile = target

    #if target is a directory a new file with the same name will be created
    if fs.existsSync(target) && fs.lstatSync(target).isDirectory()
      targetFile = path.join(target, path.basename(source))

    fs.createReadStream(source).pipe(fs.createWriteStream(targetFile))

  @cpFileFromUrl = (sourceUrl, target, cb) ->
    http = Npm.require("https")
    fs = Npm.require("fs")
    file = fs.createWriteStream(target)

    http.get sourceUrl, (response) ->
      response.pipe file
      file.on 'finish', ->
        file.close () ->
          cb (target) if cb
    .on 'error', (e) ->
      fs.unlink(target);
      console.error("Cannot download file from URL" + e.message);
      cb(null)

  ## ensure dir exists or create dir recursively
  @ensureDir = (path) ->
    fs = Npm.require('fs')

    dirs = path.split("/")
    dirs = dirs.slice(1)

    createDir = ""
    dirs.forEach (dir) ->
      createDir += "/" + dir
      unless fs.existsSync(createDir)
        try
          fs.mkdirSync createDir
        catch e
          throw new Error(e) unless fs.statSync(createDir).isDirectory()

  @baseName = (name) ->
    path = Npm.require('path')
    path.basename(name)