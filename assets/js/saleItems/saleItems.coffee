angular.module('awesomeCRM.saleItems', [
  'ui.router'
  'awesomeCRM.saleItems.provider'
]).controller('awesomeCRM.saleItems.indexController', ($scope, formErrorHandler, saleItemsProvider, offersProvider, ordersProvider, deliveriesProvider, invoicesProvider, debounce) ->
  offer = null
  order = null
  canAdd = true

  if $scope.offer
    offer = parentEntity = $scope.offer
    parentProvider = offersProvider
  else if $scope.order
    order = parentEntity = $scope.order
    parentProvider = ordersProvider
  else if $scope.delivery
    delivery = parentEntity = $scope.delivery
    parentProvider = deliveriesProvider
  else if $scope.invoice
    invoice = parentEntity = $scope.invoice
    parentProvider = invoicesProvider
  else
    throw 'saleItems indexController requires offer, delivery, invoice or order to be set in the scope'
  sale = $scope.sale

  $scope.sum = 0
  $scope.totalPrice = 0
  $scope.editable = true
  $scope.stateEditable = true

  watch = (saleItem) ->
    $scope.$watch(
      () -> JSON.stringify(saleItem)
      debounce(1000, (newValue, oldValue) ->
        return if newValue == oldValue
        saleItemsProvider.update(saleItem)
      )
    )
    saleItem.amount ?= 0
    saleItem.price ?= 0
    $scope.sum += saleItem.amount*1
    $scope.totalPrice += saleItem.amount*saleItem.price
    $scope.$watch(
      () -> saleItem.amount
      (newValue, oldValue) ->
        newValue ?= 0
        oldValue ?= 0
        $scope.sum += newValue*1 - oldValue*1
    )
    $scope.$watch(
      () -> saleItem.amount * saleItem.price
      (newValue, oldValue) ->
        newValue ?= 0
        oldValue ?= 0
        $scope.totalPrice += newValue*1 - oldValue*1
    )

  parentProvider.get({id: parentEntity.id}, (parentEntity) ->
    $scope.saleItems = parentEntity.products
    watch(i) for i in $scope.saleItems
    $scope.saleItems.push({}) if canAdd
  )

  $scope.delete = (saleItem) ->
    saleItemsProvider.delete(saleItem)
    i = $scope.saleItems.indexOf(saleItem)
    $scope.saleItems.splice(i, 1) if i != -1

  $scope.add = (saleItem, fromTable = true) ->
    saleItem.offers = [offer] if offer
    saleItem.orders = [order] if order
    saleItem.deliveries = [delivery] if delivery
    saleItem.invoices = [invoice] if invoice
    saleItem.sale = sale
    saleItem.state = 'New'
    saleItemsProvider.save(
      saleItem,
      (newSaleItem) ->
        $scope.errors = null
        saleItem.id = newSaleItem.id
        watch(saleItem)
        if fromTable
          $scope.saleItems.push({})
        else
          $scope.saleItems.splice($scope.saleItems.length - 1, 0, saleItem)

      (res) ->
        $scope.errors = res.data.details
    )

  $scope.selectedTemplate = null
  $scope.addFromTemplate = (template) ->
    $scope.add({
      name: template.name
      description: template.description
      type: template.type
      price: template.price
      currency: template.currency
      amount: 0
      productTemplate: template
    }, false)

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
  return staticSelect(defaultValue: 'New', noneSelectedLabel: 'No Type', items: ['New', 'Production', 'Ready', 'Delivery', 'Delivered'])
])
