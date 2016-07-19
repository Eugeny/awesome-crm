angular.module('awesomeCRM.saleItems', [
  'ui.router'
  'awesomeCRM.saleItems.provider'
]).controller('awesomeCRM.saleItems.indexController', ($scope, saleItemsProvider, offersProvider, debounce) ->
  offer = $scope.offer
  sale = $scope.sale

  $scope.sum = 0

  watch = (saleItem) ->
    $scope.$watch(
      () -> JSON.stringify(saleItem)
      debounce(1000, (newValue, oldValue) ->
        return if newValue == oldValue
        saleItemsProvider.update(saleItem)
      )
    )
    $scope.$watch(
      () -> saleItem.amount
      (newValue, oldValue) ->
        newValue ?= 0
        oldValue ?= 0
        $scope.sum += newValue*1 - oldValue*1
    )

  offersProvider.get({id: offer.id}, (offer) ->
    $scope.saleItems = offer.products
    watch(i) for i in $scope.saleItems
    $scope.saleItems.push({}) if offer.active and sale.state == 'Offer'
  )

  $scope.delete = (saleItem) ->
    saleItemsProvider.delete(saleItem)
    i = $scope.saleItems.indexOf(saleItem)
    $scope.saleItems.splice(i, 1) if i != -1

  $scope.add = (saleItem) ->
    saleItem.offer = [offer]
    saleItem.sale = sale
    saleItem.state = 'New'
    saleItemsProvider.save(saleItem, (newSaleItem) ->
      saleItem.id = newSaleItem.id
      watch(saleItem)
      $scope.saleItems.push({})
      offersProvider.addProduct(id: offer.id, productId: saleItem.id)
    )

).directive('productsTable', () ->
  return {
    scope:{
      offer: '='
      sale: '='
    }
    templateUrl: '/partials/app/saleItems/index.html'
  }
)
