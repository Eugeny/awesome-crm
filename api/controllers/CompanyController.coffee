# CompanyController
#
# @description :: Server-side logic for managing Companies
# @help        :: See http://sailsjs.org/#!/documentation/concepts/Controllers

_ = require('lodash')

module.exports =
  findone: (req, res) ->
    Company.findOne(id: req.param('id'))
    .populate('comments')
    .populate('contactPerson')
    .populate('people')
    .then((company) ->
      commentUsers = User.find(id: _.map(company.comments, 'createdBy'))
      return [
        company
        commentUsers
      ]
    ).spread((company, commentUsers) ->
      commentUsers = _.keyBy(commentUsers, 'id')

      company.comments = _.map(company.comments, (comment) ->
        comment.createdBy = commentUsers[comment.createdBy]
        return comment
      )
      res.json(company)
    ).catch((err) ->
      res.serverError(err)
    )
