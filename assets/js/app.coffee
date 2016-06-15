angular.module('awesomeCRM', [
  'ui.router'
  'ngResource'
  'formstamp'
  'angularMoment'
  'countrySelect'
  'awesomeCRM.contacts'
  'awesomeCRM.companies'
  'awesomeCRM.auth'
  'awesomeCRM.index'
]).config(($stateProvider, $urlRouterProvider, $httpProvider) ->
  "ngInject"

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
);
