angular.module('awesomeCRM.sales', [
  'ui.router'
  'awesomeCRM.sales.provider'
  'awesomeCRM.countries.provider'
  'awesomeCRM.comments.provider'
  'awesomeCRM.orders.provider'
]).config(($stateProvider, $urlRouterProvider) ->
  $stateProvider.state('sales',
    url: '/sales'
    templateUrl: '/partials/app/sales/index.html'
    resolve:
      sales: (salesProvider) -> salesProvider.query()

    controller: ($scope, $state, sales, salesProvider, $uibModal) ->
      $scope.sales = sales
      $scope.filters = {}

      $scope.delete = (sale) ->
        salesProvider.delete(sale)
        i = $scope.sales.indexOf(sale)
        $scope.sales.splice(i, 1) if i != -1

      $scope.add = () ->
        $uibModal.open(
          templateUrl: '/partials/app/sales/form.html'
          controller: 'awesomeCRM.sales.formController'
          size: 'lg'
          resolve:
            sale: {}
        ).result.then((sale) ->
          $scope.sales.push(sale) if sale
        )
  )

  # Create page
  $stateProvider.state('sales.create',
    url: '/create'
    templateUrl: '/partials/app/sales/form.html'
    resolve:
      sale: () -> {}
      $uibModalInstance: () -> null
    controller: 'awesomeCRM.sales.formController'
  )

  # Update page
  $stateProvider.state('sales.edit',
    url: '/edit/{id}'
    templateUrl: '/partials/app/sales/form.html'
    resolve:
      sale: (salesProvider, $stateParams) -> salesProvider.get(id: $stateParams.id)
      $uibModalInstance: () -> null
    controller: 'awesomeCRM.sales.formController'
  )
).controller('awesomeCRM.sales.formController', ($scope, $state, salesProvider, sale, $uibModalInstance, ordersProvider, offersProvider, $q, $uibModal) ->
  sale.state ?= 'Offer'
  $scope.sale = sale

  $scope.close = (sale) ->
    if $uibModalInstance
      $uibModalInstance.close(sale)
    else
      $state.go('sales', null, {reload: true})

  $scope.save = () ->
    action = if sale.id then 'update' else 'save'
    $scope.sale.offers = [{active: true}] if !$scope.sale.offers

    salesProvider[action](
      $scope.sale,
      (sale) ->
        $scope.sale.id = sale.id
        $scope.close($scope.sale) if $uibModalInstance
      (res) ->
        $scope.errors = res.data.details
        $scope.saleForm.$setPristine()
        $scope.saleForm.$setUntouched()
        for k,i of res.data.invalidAttributes
          $scope.saleForm[k].$setDirty(true);
          for j in i
            $scope.saleForm[k].$setValidity(j.rule, false);
    )

  $scope.delete = (sale) ->
    salesProvider.delete(sale)
    $scope.close()

  $scope.setState = (state) ->
    $scope.sale.state = state
    salesProvider.update({id: sale.id}, {state: state})
    if state == 'Ordered'
      offer = $scope.sale.offers.find((x) -> x.active)
      if offer
        offersProvider.get(id: offer.id, (offer) ->
          order = angular.copy(offer)

          delete order.id
          ordersProvider.save(order, (order) ->
#            saleItemsProvider.addOrder(id: i.id, orderId: order.id) for i in offer.products
            salesProvider.addOrder(id: sale.id, orderId: order.id)
            sale.orders ?= []
            sale.orders.push(order)
          )
        )

  $scope.createInvoiceOrDelivery = () ->
    promises = (ordersProvider.get(id: o.id).$promise for o in sale.orders)
    $q.allSettled(promises).then((data) ->
      items = []
      itemMarked = []

      for i in data
        continue if i.state != 'fulfilled'

        for p in i.value.products
          if !itemMarked[p.id]
            items.push(p)
            itemMarked[p.id] = true

      $uibModal.open(
        templateUrl: '/partials/app/sales/deliveryOrInvoiceModal.html'
        controller: ($scope) ->
          $scope.saleItems = items
          $scope.sale = sale

          $scope.selected = {}
          $scope.createDelivery = () -> $scope.deliveryProducts = $scope.saleItems.filter((x) -> $scope.selected[x.id])
          $scope.createInvoice = () -> $scope.invoiceProducts = $scope.saleItems.filter((x) -> $scope.selected[x.id])

        size: 'lg'
#        resolve:
#          products: items
      )
    )
)
