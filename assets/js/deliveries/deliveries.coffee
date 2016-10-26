angular.module('awesomeCRM.deliveries', [
  'ui.router'
  'awesomeCRM.deliveries.provider'
  'awesomeCRM.countries.provider'
  'awesomeCRM.comments.provider'
]).controller('awesomeCRM.deliveries.formController', ($scope, $state, deliveriesProvider, delivery, sale, $uibModalInstance) ->
  $scope.delivery = delivery
  $scope.sale = sale
  $scope.shown = true

  $scope.close = (delivery) ->
    if $uibModalInstance
      $uibModalInstance.close(delivery)
    else
      $state.go('deliveries', null, {reload: true})

  $scope.save = () ->
    action = if delivery.id then 'update' else 'save'
    deliveriesProvider[action](
      $scope.delivery,
      (delivery) -> $scope.close(delivery)
      (res) ->
        $scope.errors = res.data.details
        $scope.deliveryForm.$setPristine()
        $scope.deliveryForm.$setUntouched()
        for k,i of res.data.invalidAttributes
          $scope.deliveryForm[k].$setDirty(true);
          for j in i
            $scope.deliveryForm[k].$setValidity(j.rule, false);
    )
).controller('awesomeCRM.deliveries.indexController', ($scope, $state, deliveriesProvider, deliveryModal) ->
  sale = $scope.sale
  $scope.deliveries = sale.deliveries

  $scope.$watch(
    () -> try $scope.sale.deliveries.length
    () -> deliveriesProvider.query({sale: sale.id}, (deliveries) -> $scope.deliveries = deliveries)
  )

  $scope.add = () ->
    delivery = angular.copy(sale.deliveries.find((o) -> o.active)) ? {}
    delete delivery.id
    delivery.active = true
    delivery.sale = sale

    deliveryModal(delivery, sale).result.then((delivery) ->
      for i in sale.deliveries
        continue if !i.active
        i.active = false
        deliveriesProvider.update(i)
      sale.deliveries.push(delivery)
    )

  $scope.edit = (delivery) -> deliveryModal(delivery, sale)

  $scope.delete = (delivery) ->
    deliveriesProvider.delete(id: delivery.id)
    i = $scope.deliveries.indexOf(delivery)
    $scope.deliveries.splice(i, 1) if i != -1

).directive('deliveriesTable', () ->
  return {
    scope:{
      sale: '='
    }
    templateUrl: '/partials/app/deliveries/index.html'
  }
).directive('deliveryForm', (deliveriesProvider, saleItemsProvider, ordersProvider, salesProvider, $q, companiesProvider) ->
  return {
    scope:{
      products: '='
      sale: '='
      order: '='
      orders: '='
    }
    templateUrl: '/partials/app/deliveries/form.html'
    link: (scope, element, attrs) ->
      sale = scope.sale
      orders = sale.orders

      scope.delivery = {
        sale: sale
        state: 'Pending'
      }

      companiesProvider.get({id: sale.company.id}, (company) ->
        scope.delivery[i] = company[i] for i in ['address', 'city', 'country', 'zip']
        scope.delivery.vatEligible = !!company.vatId
      ) if sale.company

      scope.$watch('products', (newValue) ->
        scope.delivery.products = newValue
        scope.shown = !!newValue
      )

      scope.save = () ->
        deliveriesProvider.save(scope.delivery, (delivery) ->
          scope.shown = false
#          salesProvider.addDelivery(id: sale.id, deliveryId: delivery.id)
          updates = []
          for i in scope.delivery.products
            updates.push(saleItemsProvider.update({id: i.id}, {state: 'Delivery'}).$promise)
            i.state = 'Delivery'
          sale.deliveries.push(delivery)

          $q.all(updates).then(() ->
            ordersProvider.get({id: order.id}, (order) ->
              for i in order.products
                return if i.state != 'Delivery'
              #all products are in Delivery State
              sale.state = 'Closed'
              salesProvider.update({id: sale.id}, {state: 'Closed'})
            ) for order in orders
          )
        )
  }
).directive('deliveryStateSelect', ['staticSelect', (staticSelect) ->
  return staticSelect({noneSelectedLabel: 'No State', items: ['Pending', 'Delivery', 'Delivered', 'Returned', 'Failed']})
]).factory('deliveryModal', ['$uibModal', ($uibModal) ->
  return (delivery, sale) ->
    $uibModal.open(
      templateUrl: '/partials/app/deliveries/form.html'
      controller: 'awesomeCRM.deliveries.formController'
      size: 'lg'
      resolve:
        delivery: delivery
        sale: sale
    )
])

