 # Order.coffee
 #
 # @description :: TODO: You might write a short summary of how this model works and what it represents here.
 # @docs        :: http://sailsjs.org/documentation/concepts/models-and-orm/models

module.exports =
  attributes:
    documentId:
      type: 'integer'
#      autoIncrement: true
    sale:
      model: 'Sale'
    products:
      collection: 'SaleItem'
      via: 'orders'
      dominant: true
    comment:
      type: 'string'
    active:
      type: 'boolean'
