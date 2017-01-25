# CompanyController
#
# @description :: Server-side logic for managing Companies
# @help        :: See http://sailsjs.org/#!/documentation/concepts/Controllers

_ = require('lodash')

module.exports =
  findone: (req, res) ->
    Company.findOne(id: req.param('id'))
    .populate('contactPerson')
    .populate('people')
    .then((company) ->
      res.json(company)
    ).catch((err) ->
      res.serverError(err)
    )
