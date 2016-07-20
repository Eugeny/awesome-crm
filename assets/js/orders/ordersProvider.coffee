angular.module('awesomeCRM.orders.provider', [])
.factory('ordersProvider', ($resource) ->
  "ngInject"

  return $resource('/order/:id', {id: '@id'} , {
    update:
      method: 'PUT'
  })
)
