angular.module('awesomeCRM.offers', [
  'ui.router'
  'awesomeCRM.offers.provider'
  'awesomeCRM.countries.provider'
  'awesomeCRM.comments.provider'
]).config(($stateProvider, $urlRouterProvider) ->
  $stateProvider.state('offers',
    url: '/offers'
    templateUrl: '/partials/app/offers/index.html'
    resolve:
      offers: (offersProvider) -> offersProvider.query()

    controller: ($scope, $state, offers, offersProvider, $uibModal) ->
      $scope.offers = offers
      $scope.filters = {}

      $scope.delete = (offer) ->
        offersProvider.delete(offer)
        i = $scope.offers.indexOf(offer)
        $scope.offers.splice(i, 1) if i != -1

      $scope.add = () ->
        $uibModal.open(
          animation: $scope.animationsEnabled
          templateUrl: '/partials/app/offers/form.html'
          controller: 'awesomeCRM.offers.formController'
          resolve:
            offer: {}
        ).result.then((offer) ->
          $scope.offers.push(offer)
        )
  )

  # Create page
  $stateProvider.state('offers.create',
    url: '/create'
    templateUrl: '/partials/app/offers/form.html'
    resolve:
      offer: () -> {}
      $uibModalInstance: () -> null
    controller: 'awesomeCRM.offers.formController'
  )

  # Update page
  $stateProvider.state('offers.edit',
    url: '/edit/{id}'
    templateUrl: '/partials/app/offers/form.html'
    resolve:
      offer: (offersProvider, $stateParams) -> offersProvider.get(id: $stateParams.id)
      $uibModalInstance: () -> null
    controller: 'awesomeCRM.offers.formController'
  )
).controller('awesomeCRM.offers.formController', ($scope, $state, offersProvider, offer, $uibModalInstance) ->
  $scope.offer = offer

  $scope.close = () ->
    if $uibModalInstance
      $uibModalInstance.close($scope.offer)
    else
      $state.go('offers', null, {reload: true})

  $scope.save = () ->
    action = if offer.id then 'update' else 'save'
    offersProvider[action](
      $scope.offer,
      () -> $scope.close()
      (res) ->
        $scope.errors = res.data.details
        $scope.offerForm.$setPristine()
        $scope.offerForm.$setUntouched()
        for k,i of res.data.invalidAttributes
          $scope.offerForm[k].$setDirty(true);
          for j in i
            $scope.offerForm[k].$setValidity(j.rule, false);
    )
)
