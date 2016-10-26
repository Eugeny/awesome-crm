angular.module('awesomeCRM.orders', [
  'ui.router'
  'awesomeCRM.orders.provider'
  'awesomeCRM.countries.provider'
  'awesomeCRM.comments.provider'
]).controller('awesomeCRM.orders.formController', ($scope, $state, ordersProvider, order, sale, $uibModalInstance) ->
  $scope.order = order
  $scope.sale = sale

  $scope.close = (order) ->
    if $uibModalInstance
      $uibModalInstance.close(order)
    else
      $state.go('orders', null, {reload: true})

  $scope.save = () ->
    action = if order.id then 'update' else 'save'
    ordersProvider[action](
      $scope.order,
      (order) -> $scope.close(order)
      (res) ->
        $scope.errors = res.data.details
        $scope.orderForm.$setPristine()
        $scope.orderForm.$setUntouched()
        for k,i of res.data.invalidAttributes
          $scope.orderForm[k].$setDirty(true);
          for j in i
            $scope.orderForm[k].$setValidity(j.rule, false);
    )

).controller('awesomeCRM.orders.indexController', ($scope, $state, ordersProvider, orderModal) ->
  sale = $scope.sale

  $scope.add = () ->
    order = angular.copy(sale.orders.find((o) -> o.active)) ? {}
    delete order.id
    order.active = true
    order.sale = sale

    orderModal(order, sale).result.then((order) ->
      for i in sale.orders
        continue if !i.active
        i.active = false
        ordersProvider.update(i)
      sale.orders.push(order)
    )

  $scope.edit = (order) -> orderModal(order, sale)

  $scope.delete = (order) ->
    ordersProvider.delete(id: order.id)
    i = $scope.sale.orders.indexOf(order)
    $scope.sale.orders.splice(i, 1) if i != -1

).directive('ordersTable', () ->
  return {
    scope:{
      sale: '='
    }
    templateUrl: '/partials/app/orders/index.html'
  }
).factory('orderModal', ['$uibModal', ($uibModal) ->
  return (order, sale) ->
    $uibModal.open(
      templateUrl: '/partials/app/orders/form.html'
      controller: 'awesomeCRM.orders.formController'
      size: 'lg'
      resolve:
        order: order
        sale: sale
    )
])

