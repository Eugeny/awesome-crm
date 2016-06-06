angular.module('awesomeCRM.contacts.provider', [])
.factory('contactsProvider', [
  '$http'
  ($http) ->
    path = '/contact'
    contacts = $http.get(path).then((resp) -> resp.data)

    factory = {}

    factory.all = () -> contacts
    factory.get = (id) -> $http.get("#{path}/#{id}").then((resp) -> resp.data)
    factory.create = (contact) -> $http.post(path, contact).then((resp) -> resp.data)
    factory.update = (contact) -> $http.put("#{path}/#{contact.id}", contact).then((resp) -> resp.data)
    factory.delete = (contact) -> $http.delete("#{path}/#{contact.id}").then((resp) -> resp.data)

    factory
])
