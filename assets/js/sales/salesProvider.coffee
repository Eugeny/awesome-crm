angular.module('awesomeCRM.sales.provider', [])
.factory('salesProvider', ($resource) ->
  "ngInject"

  return $resource('/sale/:id', {id: '@id'} , {
    update:
      method: 'PUT'
  })
)
