# PersonController
#
# @description :: Server-side logic for managing People
# @help        :: See http://sailsjs.org/#!/documentation/concepts/Controllers

_ = require('lodash')

module.exports =

  findone: (req, res) ->
    Person.findOne(id: req.param('id'))
    .populate('company')
    .populate('comments')
    .then((person) ->
      commentUsers = User.find(id: _.map(person.comments, 'createdBy'))
      return [
        person
        commentUsers
      ]
    ).spread((person, commentUsers) ->
      commentUsers = _.keyBy(commentUsers, 'id')

      person.comments = _.map(person.comments, (comment) ->
        comment.createdBy = commentUsers[comment.createdBy]
        return comment
      )
      res.json(person)
    ).catch((err) ->
      res.serverError(err)
    )

