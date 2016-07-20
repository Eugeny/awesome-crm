angular.module('awesomeCRM.deliveries.provider', [])
.factory('deliveriesProvider', ($resource) ->
  "ngInject"

  return $resource('/delivery/:id', {id: '@id'} , {
    update:
      method: 'PUT'
    query:
      method: 'GET'
      isArray: true
      transformResponse: (response) ->
        deliveries = JSON.parse(response)
        for i,k in deliveries
          deliveries[k].startDate = new Date(i.startDate)
          deliveries[k].endDate = new Date(i.endDate)
        return deliveries
  })
)
