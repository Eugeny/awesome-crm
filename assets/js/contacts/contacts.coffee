angular.module('awesomeCRM.contacts', [
  'ui.router'
  'awesomeCRM.contacts.provider'
]).config(($stateProvider, $urlRouterProvider) ->
  $stateProvider.state('contacts',
    url: '/contacts'
    templateUrl: '/partials/app/contacts/index.html'
    resolve:
      contacts: (contactsProvider) ->
        contactsProvider.query()

    controller: ($scope, $state, contacts, contactsProvider) ->
      $scope.contacts = contacts
      $scope.delete = (contact, k = -1) ->
        contactsProvider.delete(contact)
        $scope.contacts.splice(k, 1) if k != -1
  )

  # Create page
  $stateProvider.state('contacts.create',
    url: '/create'
    templateUrl: '/partials/app/contacts/form.html'
    controller: ($scope, $state, contactsProvider) ->
      $scope.contact = {}

      $scope.save = () ->
        contactsProvider.save($scope.contact, () -> $state.go('contacts', null, {reload: true}))
  )

  # Update page
  $stateProvider.state('contacts.update',
    url: '/update/{id}'
    templateUrl: '/partials/app/contacts/form.html'
    resolve:
      contact: (contactsProvider, $stateParams) ->
        contactsProvider.get(id: $stateParams.id)

    controller: ($scope, $state, contact, contactsProvider) ->
      $scope.contact = contact

      $scope.save = () ->
        contactsProvider.update($scope.contact, () -> $state.go('contacts', null, {reload: true}))
  )
);
