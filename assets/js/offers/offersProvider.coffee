angular.module('awesomeCRM.offers.provider', [])
.factory('offersProvider', ($resource) ->
  "ngInject"

  return $resource('/offer/:id', {id: '@id'} , {
    update:
      method: 'PUT'

    addProduct:
      method: 'POST'
      url: '/offer/:id/products/:productId'
      params:
        id: '@id'
        productId: '@productId'
  })
)
