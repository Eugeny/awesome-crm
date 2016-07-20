angular.module('awesomeCRM.sales.provider', [])
.factory('salesProvider', ($resource) ->
  "ngInject"

  return $resource('/sale/:id', {id: '@id'} , {
    update:
      method: 'PUT'

    addOrder:
      method: 'POST'
      url: '/sale/:id/orders/:orderId'
      params:
        id: '@id'
        orderId: '@orderId'
  })
)
