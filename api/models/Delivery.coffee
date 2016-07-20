# Delivery.coffee
#
# @description :: TODO: You might write a short summary of how this model works and what it represents here.
# @docs        :: http://sailsjs.org/documentation/concepts/models-and-orm/models

module.exports =
  attributes:
    sale:
      model: 'Sale'
    address:
      type: 'string'
    zip:
      type: 'string'
    city:
      type: 'string'
    country:
      type: 'string'
    state:
      type: 'string'
    startDate:
      type: 'datetime'
    endDate:
      type: 'datetime'
    tracking:
      type: 'string'
    products:
      collection: 'SaleItem'
      via: 'deliveries'
      dominant: true
