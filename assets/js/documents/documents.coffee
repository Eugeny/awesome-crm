angular.module('awesomeCRM.documents', [
  'ui.router'
]).config(($stateProvider, $urlRouterProvider) ->
  $stateProvider.state('documents',
    url: '/documents/:type'
    templateUrl: '/partials/app/documents/index.html'

    controller: ($scope, $stateParams, offersProvider, ordersProvider, invoicesProvider, deliveriesProvider) ->
      $scope.type = type = $stateParams.type

      cb = (docs) -> $scope.documents = docs

      switch type
        when 'offer'
          offersProvider.query(cb)
          title = 'Offers'
        when 'order'
          ordersProvider.query(cb)
          title = 'Orders'
        when 'invoice'
          invoicesProvider.query(cb)
          title = 'Invoices'
        when 'delivery'
          deliveriesProvider.query(cb)
          title = 'Deliveries'
        else return

      $scope.title = title
  )
)
