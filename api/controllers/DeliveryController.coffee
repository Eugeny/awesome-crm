 # DeliveryController
 #
 # @description :: Server-side logic for managing Deliveries
 # @help        :: See http://sailsjs.org/#!/documentation/concepts/Controllers

actionUtil = require('sails/lib/hooks/blueprints/actionUtil')

module.exports =
  findone: (req, res) ->
    Delivery.findOne(id: req.param('id'))
    .populate('products')
    .then((delivery) ->
      res.json(delivery)
    ).catch((err) ->
      res.serverError(err)
    )

  find: (req, res) ->
    Delivery.find()
    .populate('products')
    .where( actionUtil.parseCriteria(req) )
    .limit( actionUtil.parseLimit(req) )
    .skip( actionUtil.parseSkip(req) )
    .sort( actionUtil.parseSort(req) )
    .then((delivery) ->
      res.json(delivery)
    ).catch((err) ->
      res.serverError(err)
    )



