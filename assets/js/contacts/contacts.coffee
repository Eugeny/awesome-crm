angular.module('awesomeCRM.contacts', [
  'ui.router'
  'awesomeCRM.contacts.provider'
]).config(($stateProvider, $urlRouterProvider) ->
  "ngInject"

  $stateProvider.state('contacts',
    url: '/contacts'
    templateUrl: '/partials/app/contacts/index.html'
    resolve:
      contacts: (contactsProvider) ->
        "ngInject"
        contactsProvider.query()

    controller: ($scope, $state, contacts, contactsProvider) ->
      "ngInject"

      $scope.contacts = contacts
      $scope.delete = (contact, k) ->
        contactsProvider.delete(contact)
        $scope.contacts.splice(k, 1) if k

    reload: false
  )

  # Create page
  .state('contacts.create',
    url: '/create'
    templateUrl: '/partials/app/contacts/form.html'
    controller: ($scope, $state, contactsProvider) ->
      "ngInject"
      $scope.contact = {}

      $scope.save = () ->
        contactsProvider.save($scope.contact, () -> $state.go('contacts'))
  )

  # Update page
  .state('contacts.update',
    url: '/update/{id}'
    templateUrl: '/partials/app/contacts/form.html'
    resolve:
      contact: (contactsProvider, $stateParams) ->
        "ngInject"
        contactsProvider.get(id: $stateParams.id)

    controller: ($scope, $state, contact, contactsProvider) ->
      "ngInject"
      $scope.contact = contact

      $scope.save = () ->
        contactsProvider.update($scope.contact, () -> $state.go('contacts'))
  )
);
