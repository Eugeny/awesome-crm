angular.module('awesomeCRM', [
  'ui.router'
  'ngResource'
  'formstamp'
  'awesomeCRM.contacts'
]).config(($stateProvider, $urlRouterProvider) ->
  "ngInject"

  $urlRouterProvider.otherwise("/");
);
