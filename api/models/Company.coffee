 # Company.coffee
 #
 # @description :: TODO: You might write a short summary of how this model works and what it represents here.
 # @docs        :: http://sailsjs.org/documentation/concepts/models-and-orm/models

module.exports =
  attributes:
    name:
      type: 'string'
      required: true
    address:
      type: 'string'
    zip:
      type: 'string'
    city:
      type: 'string'
    country:
      type: 'string'
    type:
      type: 'string'
    subtype:
      type: 'string'
    fax:
      type: 'string'
    email:
      type: 'string'
    website:
      type: 'string'
    vatId:
      type: 'string'
    comments:
      collection: 'Comment'
      via: 'company'
    people:
      collection: 'Person'
      via: 'company'


# Country / selection
# Type / selection: (End Customer, Partner, Potential Partner, Supplier, Marketing, Other)
# Subtype / selection: (Broadcast, Postproduction, manual input)
