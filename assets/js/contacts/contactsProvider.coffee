angular.module('awesomeCRM.contacts.provider', [])
.factory('contactsProvider', ($resource) ->
  "ngInject"

  return $resource('/contact/:id', {id: '@id'} , {
    update: {
      method: 'PUT'
    }
  })
)
