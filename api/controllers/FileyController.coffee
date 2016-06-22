# FileyController
#
# @description :: Server-side logic for managing files
# @help        :: See http://sailsjs.org/#!/documentation/concepts/Controllers

fs = require('fs');
path = require('path');
mkdirp = require('mkdirp');

module.exports =
  upload: (req, res) ->
    req.file('files').upload((err, files) ->
      if err
        return res.serverError(err)

      for i,k in files
        oldPath = i.fd
        newPath = oldPath.replace('.tmp/', '')
        files[k].fd = newPath.match(/\/uploads.*$/)[0]

        do (oldPath, newPath) -> 
          mkdirp(path.dirname(newPath), () ->
            fs.rename(oldPath, newPath)
          )

      res.json(files)
    )

