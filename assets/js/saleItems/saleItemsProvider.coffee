angular.module('awesomeCRM.saleItems.provider', [])
.factory('saleItemsProvider', ($resource) ->
  "ngInject"

  return $resource('/saleItem/:id', {id: '@id'} , {
    update:
      method: 'PUT'
  })
)
