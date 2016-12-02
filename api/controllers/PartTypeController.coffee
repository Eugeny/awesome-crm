 # PartTypeController
 #
 # @description :: Server-side logic for managing Parttypes
 # @help        :: See http://sailsjs.org/#!/documentation/concepts/Controllers

Promise = require("bluebird")

module.exports =
  findone: (req, res) ->
    PartType.findOne(id: req.param('id'))
    .populate('supplier')
    .then((partType) ->
      res.json(partType)
    ).catch((err) ->
      res.serverError(err)
    )

  find: (req, res) ->
    PartType.find()
    .populate('supplier')
    .then((partTypes) ->
      promises = []
      for i in partTypes
        do (i) ->
          for j in [0,1]
            do (j) ->
              p = new Promise((resolve) ->
                Part.count({type: i.id, isAvailable: !!j}).exec((error, count) ->
                  i.partsCount ?= {}
                  i.partsCount[j] = count
                  resolve()
                )
              )
              promises.push(p)

      Promise.all(promises).then(() ->
        res.json(partTypes)
      )
    ).catch((err) ->
      res.serverError(err)
    )

