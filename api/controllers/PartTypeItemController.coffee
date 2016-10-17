# PartTypeItemController
#
# @description :: Server-side logic for managing Parttypeitems
# @help        :: See http://sailsjs.org/#!/documentation/concepts/Controllers

populate = (x) ->
  x.populate('partType')

module.exports =
  findone: (req, res) ->
    populate(PartTypeItem.findOne(id: req.param('id')))
    .then((partTypeItem) ->
      res.json(partTypeItem)
    ).catch((err) ->
      res.serverError(err)
    )

  find: (req, res) ->
    populate(PartTypeItem.find(productTemplate: req.param('productTemplate')))
    .then((partTypeItems) ->
      res.json(partTypeItems)
    ).catch((err) ->
      res.serverError(err)
    )
