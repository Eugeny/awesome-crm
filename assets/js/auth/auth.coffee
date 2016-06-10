angular.module('awesomeCRM.auth', [
  'ui.router'
  'awesomeCRM.auth.provider'
]).config(($stateProvider, $urlRouterProvider) ->
  $stateProvider.state('auth',
    url: '/auth'
    templateUrl: '/partials/app/auth/index.html'

    controller: ($scope, authProvider) ->
      $scope.credentials = {}
      $scope.login = authProvider.login
  )
).controller('AuthController', ($scope, authProvider) ->
  $scope.loggedIn = true
  $scope.logout = authProvider.logout

  $scope.$watch(
    () -> authProvider.loggedIn(),
    () -> $scope.loggedIn = authProvider.loggedIn()
  )
);
