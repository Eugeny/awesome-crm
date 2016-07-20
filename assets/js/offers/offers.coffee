angular.module('awesomeCRM.offers', [
  'ui.router'
  'awesomeCRM.offers.provider'
  'awesomeCRM.countries.provider'
  'awesomeCRM.comments.provider'
]).controller('awesomeCRM.offers.formController', ($scope, $state, offersProvider, offer, sale, $uibModalInstance) ->
  $scope.offer = offer
  $scope.sale = sale

  $scope.close = (offer) ->
    if $uibModalInstance
      $uibModalInstance.close(offer)
    else
      $state.go('offers', null, {reload: true})

  $scope.save = () ->
    action = if offer.id then 'update' else 'save'
    offersProvider[action](
      $scope.offer,
      (offer) -> $scope.close(offer)
      (res) ->
        $scope.errors = res.data.details
        $scope.offerForm.$setPristine()
        $scope.offerForm.$setUntouched()
        for k,i of res.data.invalidAttributes
          $scope.offerForm[k].$setDirty(true);
          for j in i
            $scope.offerForm[k].$setValidity(j.rule, false);
    )
).controller('awesomeCRM.offers.indexController', ($scope, $state, offersProvider, $uibModal) ->
  sale = $scope.sale

  $scope.add = () ->
    offer = angular.copy(sale.offers.find((o) -> o.active)) ? {}
    delete offer.id
    offer.active = true
    offer.sale = sale

    $uibModal.open(
      templateUrl: '/partials/app/offers/form.html'
      controller: 'awesomeCRM.offers.formController'
      size: 'lg'
      resolve:
        offer: offer
        sale: sale

    ).result.then((offer) ->
      for i in sale.offers
        continue if !i.active
        i.active = false
        offersProvider.update(i)
      sale.offers.push(offer)
    )

  $scope.edit = (offer) ->
    $uibModal.open(
      templateUrl: '/partials/app/offers/form.html'
      controller: 'awesomeCRM.offers.formController'
      size: 'lg'
      resolve:
        offer: offer
        sale: sale
    )

).directive('offersTable', () ->
  return {
    scope:{
      sale: '='
    }
    templateUrl: '/partials/app/offers/index.html'
  }
)
