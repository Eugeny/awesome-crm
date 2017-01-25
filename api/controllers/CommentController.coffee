# CommentController
#
# @description :: Server-side logic for managing Comments
# @help        :: See http://sailsjs.org/#!/documentation/concepts/Controllers

actionUtil = require('sails/lib/hooks/blueprints/actionUtil')

populate = (x) ->
  x.populate('files')
    .populate('createdBy')

module.exports =
  findone: (req, res) ->
    populate(Comment.findOne(id: req.param('id')))
      .then((comment) ->
      res.json(comment)
    ).catch((err) ->
      res.serverError(err)
    )

  find: (req, res) ->
    populate(Comment.find()
      .where( actionUtil.parseCriteria(req) )
      .limit( actionUtil.parseLimit(req) )
      .skip( actionUtil.parseSkip(req) )
      .sort( actionUtil.parseSort(req) )
    ).then((comments) ->
      res.json(comments)
    ).catch((err) ->
      res.serverError(err)
    )
