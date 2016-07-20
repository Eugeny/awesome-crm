angular.module('awesomeCRM.invoices.provider', [])
.factory('invoicesProvider', ($resource) ->
  "ngInject"

  return $resource('/invoice/:id', {id: '@id'} , {
    update:
      method: 'PUT'
  })
)
