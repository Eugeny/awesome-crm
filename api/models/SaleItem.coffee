 # SaleItem.coffee
 #
 # @description :: TODO: You might write a short summary of how this model works and what it represents here.
 # @docs        :: http://sailsjs.org/documentation/concepts/models-and-orm/models

module.exports =
  attributes:
    sale:
      model: 'Sale'
    name:
      type: 'string'
      required: true
    description:
      type: 'text'
    type:
      type: 'string'
    price:
      type: 'float'
    currency:
      type: 'string'
    amount:
      type: 'float'
    discount:
      type: 'float'
    state:
      type: 'string'
    offers:
      collection: 'Offer'
      via: 'products'
    orders:
      collection: 'Order'
      via: 'products'
    deliveries:
      collection: 'Delivery'
      via: 'products'
    invoices:
      collection: 'Invoice'
      via: 'products'
    productTemplate:
      model: 'ProductTemplate'

# State / selection (New, Production, Ready, Delivery, Delivered). Default: New
