angular.module('awesomeCRM.saleItems', [
  'ui.router'
  'awesomeCRM.saleItems.provider'
]).controller('awesomeCRM.saleItems.indexController', ($q, $scope, formErrorHandler, saleItemsProvider, offersProvider, ordersProvider, deliveriesProvider, invoicesProvider, debounce, machinesProvider, partTypeItemsProvider, partReservationsProvider) ->
  offer = null
  order = null
  canAdd = true

  initialProduct =
    amount: 1
    price: 0
    purchasePrice: 0
    discount: 0
    type: 'Product'

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

  $scope.parentEntity = parentEntity
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
    saleItem.purchasePrice ?= 0
    saleItem.discount ?= 0

  saleItemsWatchLoaded = false
  $scope.$watch(
    () ->
      if $scope.saleItems
        return $scope.saleItems.map((saleItem) ->
          price = if saleItem.price then saleItem.price else 0
          amount = if saleItem.amount then saleItem.amount else 0
          purchasePrice = if saleItem.purchasePrice then saleItem.purchasePrice else 0
          discount = if saleItem.discount then saleItem.discount else 0
          vatEligible = parentEntity.vatEligible

          netPrice = amount * price
          return {
            netPrice: netPrice * (1.0 - discount / 100)
            totalPrice: netPrice * (1 + (if vatEligible then 0.19 else 0))
            purchasePrice: amount * purchasePrice
          }
        ).reduce(
          (carry, x) ->
            carry ?= {}
            for k,i of x
              carry[k] ?= 0
              carry[k] += i
            return carry
          []
        )
      else
        null
    (newValue, oldValue) ->
      return if !newValue
      for k,i of newValue
        parentEntity[k] = i if !parentEntity[k] or (saleItemsWatchLoaded and oldValue[k] != i)
      if not saleItemsWatchLoaded
        saleItemsWatchLoaded = true
    true
  )

  parentProvider.get({id: parentEntity.id}, (parentEntity) ->
    $scope.saleItems = parentEntity.products
    for i in $scope.saleItems
      i.discount ?= 0
      watch(i)
  )
  $scope.newItem = angular.copy(initialProduct)

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
        $scope.saleItems.push(saleItem)
        watch(saleItem)
        if fromTable
          $scope.newItem = angular.copy(initialProduct)
        else
          $scope.saleItems.splice($scope.saleItems.length - 1, 0, saleItem)

      (res) ->
        $scope.errors = res.data.details
    )

  $scope.selectedTemplate = null
  $scope.addFromTemplate = (template) ->
    if(!template)
      $scope.noTemplateError = true
      return
    $scope.noTemplateError = false

    $scope.add({
      name: template.name
      description: template.description
      type: template.type
      price: template.price
      purchasePrice: template.purchasePrice
      discount: 0
      currency: template.currency
      amount: 1
      productTemplate: template
    }, false)

  $scope.selected = {}
  $scope.createDelivery = () -> $scope.deliveryProducts = $scope.saleItems.filter((x) -> $scope.selected[x.id])
  $scope.createInvoice = () -> $scope.invoiceProducts = $scope.saleItems.filter((x) -> $scope.selected[x.id])

  $scope.createMachine = (saleItem) ->
    machinesProvider.save({name: "#{saleItem.name} Machine", sale: sale}, (machine) ->
      promises = []
      onPromisesAdded = () ->
        $q.all(promises).then(() -> $scope.onMachineCreated(machine) if $scope.onMachineCreated)

      promises.push(saleItemsProvider.update({id: saleItem.id}, {machine: machine}).$promise)

      # create part reservations for template parts
      if saleItem.productTemplate
        partTypeItemsProvider.query({productTemplate: saleItem.productTemplate.id ? saleItem.productTemplate}, (partTypeItems) ->
          for i in partTypeItems
            try
              j = i.count
              while j--
                console.log(j)
                promises.push(partReservationsProvider.save({machine: machine.id, partType: i.partType.id}).$promise)
          onPromisesAdded()
        )
      else
        onPromisesAdded()
    )


).directive('productsTable', () ->
  return {
    scope:{
      offer: '='
      delivery: '='
      order: '='
      invoice: '='
      sale: '='
      onMachineCreated: '='
    }
    templateUrl: '/partials/app/saleItems/index.html'
  }
).directive('productTypeSelect', ['staticSelect', (staticSelect) ->
  return staticSelect({noneSelectedLabel: 'No Type', items: ['Product', 'Work']})
]).directive('productStateSelect', ['staticSelect', (staticSelect) ->
  return staticSelect(defaultValue: 'New', noneSelectedLabel: 'No Type', items: ['New', 'Production', 'Ready', 'Delivery', 'Delivered'])
])
