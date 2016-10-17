# MachineController
#
# @description :: Server-side logic for managing Machines
# @help        :: See http://sailsjs.org/#!/documentation/concepts/Controllers

populate = (x) ->
  x.populate('company')
  .populate('sale')

module.exports =
  findone: (req, res) ->
    populate(Machine.findOne(id: req.param('id')))
    .then((partType) ->
      res.json(partType)
    ).catch((err) ->
      res.serverError(err)
    )

  find: (req, res) ->
    populate(Machine.find())
    .then((partTypes) ->
      res.json(partTypes)
    ).catch((err) ->
      res.serverError(err)
    )
