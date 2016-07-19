angular.module('awesomeCRM.offers.provider', [])
.factory('offersProvider', ($resource) ->
  "ngInject"

  return $resource('/offer/:id', {id: '@id'} , {
    update:
      method: 'PUT'
  })
)
