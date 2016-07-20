 # OrderController
 #
 # @description :: Server-side logic for managing Orders
 # @help        :: See http://sailsjs.org/#!/documentation/concepts/Controllers

module.exports =
  findone: (req, res) ->
    Order.findOne(id: req.param('id'))
    .populate('products')
    .then((offer) ->
      res.json(offer)
    ).catch((err) ->
      res.serverError(err)
    )
