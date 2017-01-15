# Machine.coffee
#
# @description :: TODO: You might write a short summary of how this model works and what it represents here.
# @docs        :: http://sailsjs.org/documentation/concepts/models-and-orm/models

module.exports =
  attributes:
    name:
      type: 'string'
    state:
      type: 'string' # [building|built|shipped]
    serialNumber:
      type: 'string'
    type:
      type: 'string' # []
    config:
      type: 'json'
    company:
      model: 'Company'
    sale:
      model: 'Sale'
    manufacturedOn:
      type: 'datetime'
    maintenanceStart:
      type: 'datetime'
    maintenanceEnd:
      type: 'datetime'
    serviceLevel:
      type: 'string' # []
    softwareRelease:
      type: 'string'
    chassis:
      type: 'string'
    backplane:
      type: 'string'
    stornextLicense:
      type: 'text'
    stornextSN:
      type: 'string'
    cvfsID:
      type: 'string'
    comment:
      type: 'string'
