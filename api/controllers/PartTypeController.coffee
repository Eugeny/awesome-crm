 # PartTypeController
 #
 # @description :: Server-side logic for managing Parttypes
 # @help        :: See http://sailsjs.org/#!/documentation/concepts/Controllers

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
      res.json(partTypes)
    ).catch((err) ->
      res.serverError(err)
    )

