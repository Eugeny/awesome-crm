# PersonController
#
# @description :: Server-side logic for managing People
# @help        :: See http://sailsjs.org/#!/documentation/concepts/Controllers

_ = require('lodash')

module.exports =

  findone: (req, res) ->
    Person.findOne(id: req.param('id'))
    .populate('company')
    .then((person) ->
      res.json(person)
    ).catch((err) ->
      res.serverError(err)
    )

