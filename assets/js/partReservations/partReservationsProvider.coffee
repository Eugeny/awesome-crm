angular.module('awesomeCRM.partReservations.provider', [])
.factory('partReservationsProvider', ($resource) ->
  "ngInject"

  return $resource('/partReservation/:id', {id: '@id'} , {
    update:
      method: 'PUT'
    query:
      method: 'GET'
      isArray: true
      transformResponse: (response) ->
        plural = JSON.parse(response)
        for i,k in plural
          for j in []
            plural[k][j] = new Date(i[j])
        return plural
  })
)
