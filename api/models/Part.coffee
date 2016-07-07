 # Part.coffee
 #
 # @description :: TODO: You might write a short summary of how this model works and what it represents here.
 # @docs        :: http://sailsjs.org/documentation/concepts/models-and-orm/models

module.exports =
  attributes:
    type:
      model: 'PartType'
    barcode:
      type: 'string'
      unique: true
      required: true
    location:
      type: 'string'
