 # SaleController
 #
 # @description :: Server-side logic for managing Sales
 # @help        :: See http://sailsjs.org/#!/documentation/concepts/Controllers

module.exports =
  findone: (req, res) ->
    Sale.findOne(id: req.param('id'))
    .populate('company')
    .populate('companyContact')
    .populate('localContact')
    .populate('offers')
    .populate('orders')
    .then((partType) ->
      res.json(partType)
    ).catch((err) ->
      res.serverError(err)
    )

  find: (req, res) ->
    Sale.find()
    .populate('company')
    .populate('companyContact')
    .populate('localContact')
    .populate('offers')
    .populate('orders')
    .then((partTypes) ->
      res.json(partTypes)
    ).catch((err) ->
      res.serverError(err)
    )


