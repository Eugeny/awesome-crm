 # ProductTemplateController
 #
 # @description :: Server-side logic for managing Producttemplates
 # @help        :: See http://sailsjs.org/#!/documentation/concepts/Controllers

module.exports =
  findone: (req, res) ->
    ProductTemplate.findOne(id: req.param('id'))
    .populate('partTypes')
    .then((productTemplate) ->
      res.json(productTemplate)
    ).catch((err) ->
      res.serverError(err)
    )

  find: (req, res) ->
    ProductTemplate.find()
    .populate('partTypes')
    .then((productTemplates) ->
      res.json(productTemplates)
    ).catch((err) ->
      res.serverError(err)
    )
