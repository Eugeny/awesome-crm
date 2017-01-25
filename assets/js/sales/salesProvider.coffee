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

    addDelivery:
      method: 'POST'
      url: '/sale/:id/deliveries/:deliveryId'
      params:
        id: '@id'
        deliveryId: '@deliveryId'

    query:
      method: 'GET'
      isArray: true
      transformResponse: (response) ->
        sales = JSON.parse(response)
        for i,k in sales
          for j in ['expectedCloseDate']
            sales[k][j] = new Date(i[j]) if i[j]
        return sales
    get:
      method: 'GET'
      isArray: false
      transformResponse: (response) ->
        sale = JSON.parse(response)
        for j in ['expectedCloseDate']
          sale[j] = new Date(sale[j]) if sale[j]
        return sale
  })
)
