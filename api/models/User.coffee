_ = require('lodash')
_super = require('sails-permissions/api/models/User')
_.merge(exports, _super)

_.merge(exports, {
  attributes:
    firstName:
      type: 'string'
    lastName:
      type: 'string'
})
