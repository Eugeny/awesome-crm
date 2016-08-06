 # ProductTemplate.coffee
 #
 # @description :: TODO: You might write a short summary of how this model works and what it represents here.
 # @docs        :: http://sailsjs.org/documentation/concepts/models-and-orm/models

module.exports =
  attributes:
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
    partTypeItems:
      collection: 'PartTypeItem'
      via: 'productTemplates'
      dominant: true
