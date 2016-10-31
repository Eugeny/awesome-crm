angular.module('awesomeCRM.documents', [
  'ui.router'
]).config(($stateProvider, $urlRouterProvider) ->
  $stateProvider.state('documents',
    url: '/documents/:type'
    templateUrl: '/partials/app/documents/index.html'

    controller: ($scope, $stateParams, $state, salesProvider, offersProvider, ordersProvider, invoicesProvider, deliveriesProvider, invoiceModal, offerModal, orderModal, deliveryModal) ->
      $scope.type = type = $stateParams.type

      cb = (docs) -> $scope.documents = docs

      switch type
        when 'offer'
          editModal = offerModal
          offersProvider.query(cb)
          title = 'Offers'
        when 'order'
          editModal = orderModal
          ordersProvider.query(cb)
          title = 'Orders'
        when 'invoice'
          editModal = invoiceModal
          invoicesProvider.query(cb)
          title = 'Invoices'
        when 'delivery'
          editModal = deliveryModal
          deliveriesProvider.query(cb)
          title = 'Deliveries'
        else return

      $scope.title = title
      $scope.go = (entity) ->
        if typeof entity.sale == 'object'
          editModal(entity, entity.sale)
        else
          salesProvider.get(id: entity.sale, (sale) -> entity.sale = sale; $scope.go(entity))
  )
)
