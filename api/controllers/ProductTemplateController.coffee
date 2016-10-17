# ProductTemplateController
#
# @description :: Server-side logic for managing Producttemplates
# @help        :: See http://sailsjs.org/#!/documentation/concepts/Controllers

_ = require('lodash')

module.exports =
  findone: (req, res) ->
    ProductTemplate.findOne(id: req.param('id'))
    .populate('partTypeItems')
    .then((productTemplate) ->
      partTypes = PartType.find(id: (i.partType for i in productTemplate.partTypeItems))
      return [
        productTemplate
        partTypes
      ]
    ).spread((productTemplate, partTypes) ->
      partTypes = _.keyBy(partTypes, 'id')

      for i in productTemplate.partTypeItems
        i.partType = partTypes[i.partType]
      res.json(productTemplate)
    ).catch((err) ->
      res.serverError(err)
    )

  find: (req, res) ->
    ProductTemplate.find()
    .populate('partTypeItems')
    .then((productTemplates) ->
      res.json(productTemplates)
    ).catch((err) ->
      res.serverError(err)
    )
