# Invoice.coffee
#
# @description :: TODO: You might write a short summary of how this model works and what it represents here.
# @docs        :: http://sailsjs.org/documentation/concepts/models-and-orm/models

module.exports =
  attributes:
    documentId:
      type: 'integer'
      autoIncrement: true
    sale:
      model: 'Sale'
    person:
      model: 'Person'
    address:
      type: 'string'
    zip:
      type: 'string'
    city:
      type: 'string'
    country:
      type: 'string'
    products:
      collection: 'SaleItem'
      via: 'invoices'
      dominant: true
    comment:
      type: 'string'
    vatEligible:
      type: 'boolean'
    state:
      type: 'string'

    totalPrice:
      type: 'float'
    netPrice:
      type: 'float'
    purchasePrice:
      type: 'float'
