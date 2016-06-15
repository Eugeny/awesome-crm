angular.module('awesomeCRM.companies.provider', [])
.factory('companiesProvider', ($resource) ->
  "ngInject"

  return $resource('/company/:id', {id: '@id'} , {
    update:
      method: 'PUT'

    addComment:
      method: 'POST'
      url: '/company/:id/comments/:commentId'
      params:
        id: '@id'
        commentId: '@commentId'

  })
)
