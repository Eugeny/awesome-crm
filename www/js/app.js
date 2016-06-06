angular.module('myApp', ['ngRoute', 'myApp.view1', 'myApp.view2', 'myApp.version']).config([
  '$locationProvider', '$routeProvider', function($locationProvider, $routeProvider) {
    $locationProvider.hashPrefix('!');
    return $routeProvider.otherwise({
      redirectTo: '/view1'
    });
  }
]);

console.log('loaded');

//# sourceMappingURL=app.js.map
