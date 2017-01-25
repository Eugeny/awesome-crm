 # Comment.coffee
 #
 # @description :: TODO: You might write a short summary of how this model works and what it represents here.
 # @docs        :: http://sailsjs.org/documentation/concepts/models-and-orm/models

module.exports =
  attributes:
    text:
      type: 'string'
    company:
      model: 'company'
    person:
      model: 'person'
    sale:
      model: 'sale'
    machine:
      model: 'machine'
    files:
      collection: 'filey'
      via: 'comment'
