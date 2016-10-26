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

  $scope.onMachineCreated = (machine) ->
    offersProvider.update($scope.offer)
    redirect = () -> $state.go('machines.edit', {id: machine.id}, {reload: true})

    if $uibModalInstance
      $uibModalInstance.close(offer)
      $uibModalInstance.result.then(redirect)
    else
      redirect()


).controller('awesomeCRM.offers.indexController', ($scope, $state, offersProvider, offerModal) ->
  sale = $scope.sale

  $scope.add = () ->
    offer = angular.copy(sale.offers.find((o) -> o.active)) ? {}
    delete offer.id
    offer.active = true
    offer.sale = sale

    offerModal(offer, sale).result.then((offer) ->
      return if !offer

      for i in sale.offers
        continue if !i.active
        i.active = false
        offersProvider.update({id: i.id}, {active: false})

      sale.offers.push(offer)
    )

  $scope.edit = (offer) -> offerModal(offer, sale)

  $scope.delete = (offer) ->
    offersProvider.delete(id: offer.id)
    i = $scope.sale.offers.indexOf(offer)
    $scope.sale.offers.splice(i, 1) if i != -1

).directive('offersTable', () ->
  return {
    scope:{
      sale: '='
    }
    templateUrl: '/partials/app/offers/index.html'
  }
).factory('offerModal', ['$uibModal', ($uibModal) ->
  return (offer, sale) ->
    $uibModal.open(
      templateUrl: '/partials/app/offers/form.html'
      controller: 'awesomeCRM.offers.formController'
      size: 'lg'
      resolve:
        offer: offer
        sale: sale
    )
])

