angular.module('awesomeCRM.index', [
  'ui.router'
]).config(($stateProvider, $urlRouterProvider) ->
  $stateProvider.state('index',
    url: '/'
    templateUrl: '/partials/app/index/index.html'
    controller: ($scope) ->
      console.log('index')
  )
);
