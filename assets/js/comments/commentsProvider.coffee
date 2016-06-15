angular.module('awesomeCRM.comments.provider', [])
.factory('commentsProvider', ($resource) ->
  "ngInject"

  return $resource('/comment/:id', {id: '@id'} , {
    update: {
      method: 'PUT'
    }
  })
)
