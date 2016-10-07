# ExportController
#
# @description :: Server-side logic for managing Exports
# @help        :: See http://sailsjs.org/#!/documentation/concepts/Controllers

wkhtmltopdf = require('wkhtmltopdf');

injectSale = (x, callback) ->
  Sale.findOne(id: x.sale)
  .populate('company')
  .populate('localContact')
  .then((sale) ->
    x.sale = sale
    callback(x)
  )

outputExport = (res, viewOptions, pdf) ->
  view = 'export'
  viewOptions = Object.assign({
    layout: null
    moment: require('moment')
    numeral: require('numeral')
    showPrices: true
  }, viewOptions)

  if pdf
    sails.renderView(view, viewOptions, (err, html) ->
      wkhtmltopdf(html, {
        pageSize: 'A4',
        T: 0,
        B: 0,
        L: 0,
        R: 0
      }).pipe(res)
    )
  else
    res.view(view, viewOptions)


module.exports = {
  invoice: (req, res) ->
    Invoice.findOne(id: req.param('id'))
    .populate('products')
    .then((x) ->
      injectSale(x, (x) ->
        # for dev
        #        console.log(x)
        #        x.products.push(i) for i in x.products
        #        x.products.push(i) for i in x.products

        outputExport(res, {
          object: x
          type: 'Rechnung'
        }, typeof req.query['html'] == 'undefined')
      )
    )

  order: (req, res) ->
    Order.findOne(id: req.param('id'))
    .populate('products')
    .then((x) ->
      injectSale(x, (x) ->
        outputExport(res, {
          object: x
          type: 'Order'
        }, typeof req.query['html'] == 'undefined')
      )
    )

  offer: (req, res) ->
    Offer.findOne(id: req.param('id'))
    .populate('products')
    .then((x) ->
      injectSale(x, (x) ->
        outputExport(res, {
          object: x
          type: 'Offer'
        }, typeof req.query['html'] == 'undefined')
      )
    )

  delivery: (req, res) ->
    Delivery.findOne(id: req.param('id'))
    .populate('products')
    .then((x) ->
      injectSale(x, (x) ->
        outputExport(res, {
          object: x
          type: 'Lieferschein'
          showPrices: false
        }, typeof req.query['html'] == 'undefined')
      )
    )
}
