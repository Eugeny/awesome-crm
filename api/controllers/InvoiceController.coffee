# InvoiceController
#
# @description :: Server-side logic for managing Invoices
# @help        :: See http://sailsjs.org/#!/documentation/concepts/Controllers

actionUtil = require('sails/lib/hooks/blueprints/actionUtil')

module.exports =
  findone: (req, res) ->
    Invoice.findOne(id: req.param('id'))
    .populate('products')
    .populate('person')
    .then((invoice) ->
      res.json(invoice)
    ).catch((err) ->
      res.serverError(err)
    )

  find: (req, res) ->
    Invoice.find()
    .populate('products')
    .populate('person')
    .where( actionUtil.parseCriteria(req) )
    .limit( actionUtil.parseLimit(req) )
    .skip( actionUtil.parseSkip(req) )
    .sort( actionUtil.parseSort(req) )
    .then((invoice) ->
      res.json(invoice)
    ).catch((err) ->
      res.serverError(err)
    )
