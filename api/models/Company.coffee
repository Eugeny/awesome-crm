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
      required: true
    zip:
      type: 'string'
      required: true
    city:
      type: 'string'
      required: true
    country:
      type: 'string'
      required: true
    type:
      type: 'string'
      required: true
#      enum: [
#        'End Customer'
#        'Partner'
#        'Potential Partner'
#        'Supplier'
#        'Marketing'
#        'Other'
#      ]
    subtype:
      type: 'string'
#      enum: [
#        'Broadcast'
#        'Postproduction'
#      ]
    fax:
      type: 'string'
      required: true
    email:
      type: 'string'
      required: true
    website:
      type: 'string'
      required: true
    comments:
      collection: 'Comment'
      via: 'company'

# Country / selection
# Type / selection: (End Customer, Partner, Potential Partner, Supplier, Marketing, Other)
# Subtype / selection: (Broadcast, Postproduction, manual input)
