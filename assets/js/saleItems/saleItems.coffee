angular.module('awesomeCRM.saleItems', [
  'ui.router'
  'awesomeCRM.saleItems.provider'
]).controller('awesomeCRM.saleItems.indexController', ($scope, saleItemsProvider, offersProvider, ordersProvider, deliveriesProvider, invoicesProvider, debounce) ->
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
  else if $scope.delivery
    delivery = parentEntity = $scope.delivery
    parentProvider = deliveriesProvider
    $scope.stateEditable = true
  else if $scope.invoice
    invoice = parentEntity = $scope.invoice
    parentProvider = invoicesProvider
    $scope.stateEditable = true
  else
    throw 'saleItems indexController requires offer, delivery, invoice or order to be set in the scope'
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
    $scope.sum += saleItem.amount*1
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
    saleItem.offers = [offer] if offer
    saleItem.orders = [order] if order
    saleItem.deliveries = [delivery] if delivery
    saleItem.invoices = [invoice] if invoice
    saleItem.sale = sale
    saleItem.state = 'New'
    saleItemsProvider.save(saleItem, (newSaleItem) ->
      saleItem.id = newSaleItem.id
      watch(saleItem)
      $scope.saleItems.push({})
#      parentProvider.addProduct(id: parentEntity.id, productId: saleItem.id)
    )

  $scope.selected = {}
  $scope.createDelivery = () -> $scope.deliveryProducts = $scope.saleItems.filter((x) -> $scope.selected[x.id])
  $scope.createInvoice = () -> $scope.invoiceProducts = $scope.saleItems.filter((x) -> $scope.selected[x.id])

).directive('productsTable', () ->
  return {
    scope:{
      offer: '='
      delivery: '='
      order: '='
      invoice: '='
      sale: '='
    }
    templateUrl: '/partials/app/saleItems/index.html'
  }
).directive('productTypeSelect', ['staticSelect', (staticSelect) ->
  return staticSelect({noneSelectedLabel: 'No Type', items: ['Product', 'Work']})
]).directive('productStateSelect', ['staticSelect', (staticSelect) ->
  return staticSelect({noneSelectedLabel: 'No Type', items: ['New', 'Production', 'Ready', 'Delivery', 'Delivered']})
])
