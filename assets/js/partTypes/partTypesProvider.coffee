angular.module('awesomeCRM.partTypes.provider', [])
.factory('partTypesProvider', ($resource) ->
  "ngInject"

  return $resource('/partType/:id', {id: '@id'} , {
    update:
      method: 'PUT'
  })
)
