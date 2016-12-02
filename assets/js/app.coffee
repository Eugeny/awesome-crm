angular.module('awesomeCRM', [
  'ui.router'
  'ngResource'
  'formstamp'
  'angularMoment'
  'angular.filter'
  'ngFileUpload'
  'ui.bootstrap'
  'ngCookies'
  'pascalprecht.translate'
  'daterangepicker'
  'awesomeCRM.services'
  'awesomeCRM.translations'
  'awesomeCRM.people'
  'awesomeCRM.companies'
  'awesomeCRM.partTypes'
  'awesomeCRM.productTemplates'
  'awesomeCRM.partTypeItems.provider'
  'awesomeCRM.sales'
  'awesomeCRM.offers'
  'awesomeCRM.orders'
  'awesomeCRM.deliveries'
  'awesomeCRM.invoices'
  'awesomeCRM.saleItems'
  'awesomeCRM.parts'
  'awesomeCRM.auth'
  'awesomeCRM.index'
  'awesomeCRM.documents'
  'awesomeCRM.machines'
  'awesomeCRM.partReservations'
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

angular.module('awesomeCRM').config([
  '$provide'
  ($provide) ->
    $provide.decorator('$q', [
      '$delegate'
      ($delegate) ->
        $q = $delegate
        $q.allSettled = $q.allSettled or (promises) ->
#            Implementation of allSettled function from Kris Kowal's Q:
#            https://github.com/kriskowal/q/wiki/API-Reference#promiseallsettled
            wrapped = if angular.isArray(promises) then [] else {}

            wrap = (promise) ->
              $q.when(promise).then(((value) ->
                {
                  state: 'fulfilled'
                  value: value
                }
              ), (reason) ->
                {
                  state: 'rejected'
                  reason: reason
                }
              )

            angular.forEach(promises, (promise, key) ->
              if !wrapped.hasOwnProperty(key)
                wrapped[key] = wrap(promise)
              return
            )

            return $q.all(wrapped)
        return $q
    ])
    return
])
