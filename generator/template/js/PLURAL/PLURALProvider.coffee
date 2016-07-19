angular.module('awesomeCRM.PLURAL.provider', [])
.factory('PLURALProvider', ($resource) ->
  "ngInject"

  return $resource('/SINGULAR/:id', {id: '@id'} , {
    update:
      method: 'PUT'
  })
)
