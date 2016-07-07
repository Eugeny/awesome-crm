angular.module('awesomeCRM.parts.provider', [])
.factory('partsProvider', ($resource) ->
  "ngInject"

  return $resource('/part/:id', {id: '@id'} , {
    update:
      method: 'PUT'
  })
)
