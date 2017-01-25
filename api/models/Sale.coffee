 # Sale.coffee
 #
 # @description :: TODO: You might write a short summary of how this model works and what it represents here.
 # @docs        :: http://sailsjs.org/documentation/concepts/models-and-orm/models

module.exports =
  attributes:
    name:
      type: 'string'
      required: true
    company:
      model: 'Company'
    companyContact:
      model: 'Person'
    localContact:
      model: 'Person'
    techLead:
      model: 'Person'
    state:
      type: 'string'
    description:
      type: 'string'
    useCase:
      type: 'string'
    expectedRevenue:
      type: 'float'
    reasonOfLoss:
      type: 'string'
    expectedCloseDate:
      type: 'datetime'
    offers:
      collection: 'Offer'
      via: 'sale'
    orders:
      collection: 'Order'
      via: 'sale'
    orders:
      collection: 'Order'
      via: 'sale'
    deliveries:
      collection: 'Delivery'
      via: 'sale'
    invoices:
      collection: 'Invoice'
      via: 'sale'
    comments:
      collection: 'Comment'
      via: 'sale'
