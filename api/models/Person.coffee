 # Person.coffee
 #
 # @description :: TODO: You might write a short summary of how this model works and what it represents here.
 # @docs        :: http://sailsjs.org/documentation/concepts/models-and-orm/models

module.exports =
  attributes:
    firstName:
      type: 'string'
    lastName:
      type: 'string'
    position:
      type: 'string'
    hasOwnAddress:
      type: 'boolean'
    address:
      type: 'text'
    zip:
      type: 'string'
    city:
      type: 'string'
    country:
      type: 'string'
    phone:
      type: 'string'
    fax:
      type: 'string'
    email:
      type: 'string'
    company:
      model: 'Company'
    comments:
      collection: 'Comment'
      via: 'person'
