# PartController
#
# @description :: Server-side logic for managing Parts
# @help        :: See http://sailsjs.org/#!/documentation/concepts/Controllers


actionUtil = require('sails/lib/hooks/blueprints/actionUtil')
_ = require('lodash')

module.exports =
  findone: (req, res) ->
    Part.findOne(id: req.param('id'))
    .populate('type')
    .then((part) ->
      res.json(part)
    ).catch((err) ->
      res.serverError(err)
    )

  find: (req, res) ->
    Part.find()
    .populate('type')
    .where( actionUtil.parseCriteria(req) )
    .limit( actionUtil.parseLimit(req) )
    .skip( actionUtil.parseSkip(req) )
    .sort( actionUtil.parseSort(req) )
    .then((parts) ->
      res.json(parts)
    ).catch((err) ->
      res.serverError(err)
    )


