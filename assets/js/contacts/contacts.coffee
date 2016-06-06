angular.module('awesomeCRM.contacts', [
  'ui.router'
  'awesomeCRM.contacts.provider'
]).config(['$stateProvider', '$urlRouterProvider',
  ($stateProvider, $urlRouterProvider) ->

    $stateProvider.state('contacts',
      url: '/contacts'
      templateUrl: '/partials/app/contacts/index.html'
      resolve:
        contacts: [
          'contactsProvider'
          (contactsProvider) ->
            contactsProvider.all()
        ]
      controller: [
        '$scope'
        '$state'
        'contacts'
        'contactsProvider'
        ($scope, $state, contacts, contactsProvider) ->
          $scope.contacts = contacts
          $scope.delete = (contact, k) ->
            contactsProvider.delete(contact)
            $scope.contacts.splice(k, 1) if k
      ]
      reload: false
    ).state('contacts.create',
      url: '/create'
      templateUrl: '/partials/app/contacts/form.html'
      controller: [
        '$scope'
        '$state'
        'contactsProvider'
        ($scope, $state, contactsProvider) ->
          $scope.contact = {}

          $scope.save = () ->
            contactsProvider.create($scope.contact).then(() -> $state.go('contacts'))
      ]
    ).state('contacts.update',
      url: '/update/{id}'
      templateUrl: '/partials/app/contacts/form.html'
      resolve:
        contact: [
          'contactsProvider'
          '$stateParams'
          (contactsProvider, $stateParams) ->
            contactsProvider.get($stateParams.id)
        ]
      controller: [
        '$scope'
        '$state'
        'contact'
        'contactsProvider'
        ($scope, $state, contact, contactsProvider) ->
          $scope.contact = contact
          console.log(contact)

          $scope.save = () ->
            contactsProvider.update($scope.contact).then(() -> $state.go('contacts'))
      ]
    )
]);
