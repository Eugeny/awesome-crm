angular.module('awesomeCRM.partTypeItems.provider', [])
.factory('partTypeItemsProvider', ($resource) ->
  "ngInject"

  return $resource('/partTypeItem/:id', {id: '@id'} , {
    update:
      method: 'PUT'
  })
)
