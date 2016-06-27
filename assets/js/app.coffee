angular.module('awesomeCRM', [
  'ui.router'
  'ngResource'
  'formstamp'
  'angularMoment'
  'countrySelect'
  'angular.filter'
  'ngFileUpload'
  'ui.bootstrap'
  'awesomeCRM.services'
  'awesomeCRM.contacts'
  'awesomeCRM.companies'
  'awesomeCRM.auth'
  'awesomeCRM.index'
]).config(($stateProvider, $urlRouterProvider, $httpProvider, $locationProvider) ->
  "ngInject"

  $locationProvider.html5Mode(
    enabled: true
    requireBase: false
  ).hashPrefix('*');
  $httpProvider.interceptors.push(['$q', '$location', ($q, $location) ->
    return {
      'responseError': (response) ->
        status = response.status
        if status == 403
#          $injector.get('$state').transitionTo('auth')
          $location.path('/auth')

        $q.reject(response)
    }
  ])

  $urlRouterProvider.otherwise("/");
)
