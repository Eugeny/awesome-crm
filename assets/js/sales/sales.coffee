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
).controller('awesomeCRM.sales.formController', ($scope, $state, salesProvider, sale, $uibModalInstance, ordersProvider, offersProvider, deliveriesProvider, invoicesProvider, $q, $uibModal) ->
  sale.state ?= 'Offer'
  $scope.sale = sale

  $scope.close = (sale) ->
    if $uibModalInstance
      $uibModalInstance.close(sale)
      $state.go('sales.edit', {id: sale.id}, {reload: true}) if sale
    else
      if sale
        $state.go('sales.edit', {id: sale.id}, {reload: true})
      else
        $state.go('sales', null, {reload: true})

  $scope.save = () ->
    action = if sale.id then 'update' else 'save'
    $scope.sale.offers = [{active: true}] if !$scope.sale.offers

    salesProvider[action](
      $scope.sale,
      (sale) ->
        $scope.sale.id = sale.id
        $scope.close(sale)
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

  $scope.$watch('sale.state', (state, prevState) ->
    return if state == prevState
    salesProvider.update({id: sale.id}, {state: state})
    if state == 'Ordered'
      offer = $scope.sale.offers.find((x) -> x.active)
      if offer
        offersProvider.get(id: offer.id, (offer) ->
          order = angular.copy(offer)

          delete order.id
          ordersProvider.save(order, (order) ->
            salesProvider.addOrder(id: sale.id, orderId: order.id)
            sale.orders ?= []
            sale.orders.push(order)
          )
        )
  )

  $scope.createDelivery = () ->
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
        templateUrl: '/partials/app/sales/deliveryModal.html'
        controller: ($scope, $uibModalInstance, $q) ->
          $scope.saleItems = items
          $scope.sale = sale
          $scope.selected = {}
          $scope.createDelivery = () -> $scope.deliveryProducts = $scope.saleItems.filter((x) -> $scope.selected[x.id]);
          $scope.onDeliverySaved = () -> $uibModalInstance.close()
        size: 'lg'
      )
    )

  $scope.createInvoice = () ->
    promises = (deliveriesProvider.get(id: d.id).$promise for d in sale.deliveries)

    $q.allSettled(promises).then((data) ->
      deliveries = (i.value for i in data when i.state == 'fulfilled')

      $uibModal.open(
        templateUrl: '/partials/app/sales/invoiceModal.html'
        controller: ($scope, $uibModalInstance, $q) ->
          $scope.deliveries = deliveries
          $scope.sale = sale
          $scope.selected = {}
          $scope.createInvoice = () ->
            items = []
            itemMarked = []
            for i in deliveries
              continue if !$scope.selected[i.id]

              for p in i.products
                if !itemMarked[p.id]
                  items.push(p)
                  itemMarked[p.id] = true
            $scope.invoiceProducts = items

          $scope.onInvoiceSaved = () -> $uibModalInstance.close()
        size: 'lg'
      )
    )
).directive('saleSelect', ['salesProvider', 'dynamicSelect', (salesProvider, dynamicSelect) ->
  return dynamicSelect(salesProvider, 'sales', {noneSelectedLabel: 'No Sale', label: 'Sale'})
]).directive('saleStateSelect', ['staticSelect', (staticSelect) ->
  return staticSelect(label: 'State', noneSelectedLabel: 'No State', items: ['Offer', 'Ordered', 'Closed', 'Cancelled', 'Tender', 'Project Identified'])
]).directive('saleUsecaseSelect', ['staticSelect', (staticSelect) ->
  return staticSelect(label: 'Use Case', noneSelectedLabel: 'No Use Case', items: ['Avid', 'Avid+Premiere', 'OB', 'Corporate Video'], freetext: true)
])


