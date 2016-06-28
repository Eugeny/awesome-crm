angular.module('awesomeCRM.people.provider', [])
.factory('peopleProvider', ($resource) ->
  "ngInject"

  return $resource('/person/:id', {id: '@id'} , {
    update:
      method: 'PUT'

    addComment:
      method: 'POST'
      url: '/person/:id/comments/:commentId'
      params:
        id: '@id'
        commentId: '@commentId'

  })
)
