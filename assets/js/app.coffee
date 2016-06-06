angular.module('awesomeCRM', [
  'ui.router'
  'formstamp'
  'awesomeCRM.contacts'
]).config(['$stateProvider', '$urlRouterProvider',
  ($stateProvider, $urlRouterProvider) ->
    $urlRouterProvider.otherwise("/");
]);
