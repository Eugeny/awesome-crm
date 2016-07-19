 # OfferController
 #
 # @description :: Server-side logic for managing Offers
 # @help        :: See http://sailsjs.org/#!/documentation/concepts/Controllers

module.exports =
  findone: (req, res) ->
    Offer.findOne(id: req.param('id'))
    .populate('products')
    .then((offer) ->
      res.json(offer)
    ).catch((err) ->
      res.serverError(err)
    )
