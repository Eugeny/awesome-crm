angular.module('awesomeCRM.saleItems', [
  'ui.router'
  'awesomeCRM.saleItems.provider'
]).controller('awesomeCRM.saleItems.indexController', ($scope, saleItemsProvider, offersProvider, ordersProvider, debounce) ->
  offer = null
  order = null
  if $scope.offer
    offer = parentEntity = $scope.offer
    parentProvider = offersProvider
    $scope.stateEditable = false
  else if $scope.order
    order = parentEntity = $scope.order
    parentProvider = ordersProvider
    $scope.stateEditable = true
  else
    throw 'saleItems indexController requires offer or order to be set in the scope'
  sale = $scope.sale

  $scope.sum = 0
  $scope.editable = offer && offer.active && sale.state == 'Offer'

  watch = (saleItem) ->
    $scope.$watch(
      () -> JSON.stringify(saleItem)
      debounce(1000, (newValue, oldValue) ->
        return if newValue == oldValue
        saleItemsProvider.update(saleItem)
      )
    )
    $scope.sum += saleItem.amount
    $scope.$watch(
      () -> saleItem.amount
      (newValue, oldValue) ->
        newValue ?= 0
        oldValue ?= 0
        $scope.sum += newValue*1 - oldValue*1
    )

  parentProvider.get({id: parentEntity.id}, (parentEntity) ->
    $scope.saleItems = parentEntity.products
    watch(i) for i in $scope.saleItems
    $scope.saleItems.push({}) if parentEntity.active and sale.state == 'Offer'
  )

  $scope.delete = (saleItem) ->
    saleItemsProvider.delete(saleItem)
    i = $scope.saleItems.indexOf(saleItem)
    $scope.saleItems.splice(i, 1) if i != -1

  $scope.add = (saleItem) ->
    saleItem.offer = [offer] if offer
    saleItem.order = [order] if order
    saleItem.sale = sale
    saleItem.state = 'New'
    saleItemsProvider.save(saleItem, (newSaleItem) ->
      saleItem.id = newSaleItem.id
      watch(saleItem)
      $scope.saleItems.push({})
      parentProvider.addProduct(id: parentEntity.id, productId: saleItem.id)
    )

).directive('productsTable', () ->
  return {
    scope:{
      offer: '='
      order: '='
      sale: '='
    }
    templateUrl: '/partials/app/saleItems/index.html'
  }
).directive('productTypeSelect', ['staticSelect', (staticSelect) ->
  return staticSelect({noneSelectedLabel: 'No Type', items: ['Product', 'Work']})
]).directive('productStateSelect', ['staticSelect', (staticSelect) ->
  return staticSelect({noneSelectedLabel: 'No Type', items: ['New', 'Production', 'Ready', 'Delivery', 'Delivered']})
])
