# PartReservationController
#
# @description :: Server-side logic for managing Partreservations
# @help        :: See http://sailsjs.org/#!/documentation/concepts/Controllers

populate = (x) ->
  x.populate('machine')
  .populate('partType')
  .populate('part')

module.exports =
  findone: (req, res) ->
    populate(PartReservation.findOne(id: req.param('id')))
    .then((partType) ->
      res.json(partType)
    ).catch((err) ->
      res.serverError(err)
    )

  find: (req, res) ->
    populate(PartReservation.find(machine: req.param('machine')))
    .then((partTypes) ->
      res.json(partTypes)
    ).catch((err) ->
      res.serverError(err)
    )
