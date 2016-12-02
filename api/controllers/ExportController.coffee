# ExportController
#
# @description :: Server-side logic for managing Exports
# @help        :: See http://sailsjs.org/#!/documentation/concepts/Controllers

wkhtmltopdf = require('wkhtmltopdf');
wkhtmltopdf.command = sails.config.wkhtmltopdfCommand if sails.config.wkhtmltopdfCommand

injectSale = (x, callback) ->
  Sale.findOne(id: x.sale)
  .populate('company')
  .populate('localContact')
  .then((sale) ->
    x.sale = sale
    callback(x)
  )

outputExport = (res, viewOptions, language, pdf) ->
  view = "export/#{language.toLowerCase()}"
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
    language = req.query.language
    Invoice.findOne(id: req.param('id'))
    .populate('products')
    .then((x) ->
      injectSale(x, (x) ->
        # for development
        ###
        console.log(x)
        x.products.push(i) for i in x.products
        x.products.push(i) for i in x.products
        x.products.push(i) for i in x.products
        x.products.push(i) for i in x.products
        x.products.push(i) for i in x.products
        ###

        outputExport(res, {
          object: x
          type: 'Rechnung'
          typeDate: 'Rechnungsdatum'
          showPrices: true
        }, language, typeof req.query['html'] == 'undefined')
      )
    )

  order: (req, res) ->
    language = req.query.language
    Order.findOne(id: req.param('id'))
    .populate('products')
    .then((x) ->
      injectSale(x, (x) ->
        outputExport(res, {
          object: x
          type: 'Bestellung'
          typeDate: 'Bestellungsdatum'
          showPrices: true
        }, language, typeof req.query['html'] == 'undefined')
      )
    )

  offer: (req, res) ->
    language = req.query.language
    Offer.findOne(id: req.param('id'))
    .populate('products')
    .then((x) ->
      injectSale(x, (x) ->
        outputExport(res, {
          object: x
          type: 'Angebot'
          typeDate: 'Angebotsdatum'
          showPrices: true
        }, language, typeof req.query['html'] == 'undefined')
      )
    )

  delivery: (req, res) ->
    language = req.query.language
    Delivery.findOne(id: req.param('id'))
    .populate('products')
    .then((x) ->
      injectSale(x, (x) ->
        outputExport(res, {
          object: x
          type: 'Lieferschein'
          typeDate: 'Lieferscheindatum'
          showPrices: false
        }, language, typeof req.query['html'] == 'undefined')
      )
    )
}
