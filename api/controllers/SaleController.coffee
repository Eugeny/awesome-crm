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
    .populate('deliveries')
    .populate('invoices')
    .then((sale) ->
      res.json(sale)
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
    .populate('deliveries')
    .populate('invoices')
    .then((sales) ->
      res.json(sales)
    ).catch((err) ->
      res.serverError(err)
    )


