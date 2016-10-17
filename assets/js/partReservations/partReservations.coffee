angular.module('awesomeCRM.partReservations', [
  'ui.router'
  'awesomeCRM.partReservations.provider'
]).config(($stateProvider, $urlRouterProvider) ->
  $stateProvider.state('partReservations',
    url: '/partReservations'
    templateUrl: '/partials/app/partReservations/index.html'
    resolve:
      partReservations: (partReservationsProvider) -> partReservationsProvider.query()

    controller: ($scope, $state, partReservations, partReservationsProvider, $uibModal) ->
      $scope.partReservations = partReservations
      $scope.filters = {}

      $scope.delete = (partReservation) ->
        partReservationsProvider.delete(partReservation)
        i = $scope.partReservations.indexOf(partReservation)
        $scope.partReservations.splice(i, 1) if i != -1

      $scope.add = () ->
        $uibModal.open(
          templateUrl: '/partials/app/partReservations/form.html'
          controller: 'awesomeCRM.partReservations.formController'
          resolve:
            partReservation: {}
        ).result.then((partReservation) ->
          return if !partReservation
          $scope.partReservations.push(partReservation)
        )
  )

  # Create page
  $stateProvider.state('partReservations.create',
    url: '/create'
    templateUrl: '/partials/app/partReservations/form.html'
    resolve:
      partReservation: () -> {}
      $uibModalInstance: () -> null
    controller: 'awesomeCRM.partReservations.formController'
  )

  # Update page
  $stateProvider.state('partReservations.edit',
    url: '/edit/{id}'
    templateUrl: '/partials/app/partReservations/form.html'
    resolve:
      partReservation: (partReservationsProvider, $stateParams) -> partReservationsProvider.get(id: $stateParams.id)
      $uibModalInstance: () -> null
    controller: 'awesomeCRM.partReservations.formController'
  )
).controller('awesomeCRM.partReservations.formController', ($scope, $state, partReservationsProvider, $uibModalInstance) ->
  $scope.partReservation = partReservation

  $scope.close = () ->
    if $uibModalInstance
      $uibModalInstance.close($scope.partReservation)
    else
      $state.go('partReservations', null, {reload: true})

  $scope.save = () ->
    action = if partReservation.id then 'update' else 'save'
    partReservationsProvider[action](
      $scope.partReservation,
      () -> $scope.close()
      (res) ->
        $scope.errors = res.data.details
        $scope.partReservationForm.$setPristine()
        $scope.partReservationForm.$setUntouched()
        for k,i of res.data.invalidAttributes
          $scope.partReservationForm[k].$setDirty(true);
          for j in i
            $scope.partReservationForm[k].$setValidity(j.rule, false);
    )
).controller('awesomeCRM.partReservations.indexController', ($scope, formErrorHandler, partReservationsProvider, offersProvider, ordersProvider, deliveriesProvider, invoicesProvider, debounce, machinesProvider) ->
  if !$scope.machine
    throw 'saleItems indexController requires offer, delivery, invoice or order to be set in the scope'
  machine = $scope.machine

  partReservationsProvider.query({machine: machine.id}, (partReservations) ->
    $scope.partReservations = partReservations
  )

  initialPartReservation =
    machine: machine
  $scope.partReservation = angular.copy(initialPartReservation)

  $scope.addPartReservation = () ->
    partReservationsProvider.save($scope.partReservation)
    $scope.partReservations.push($scope.partReservation)
    $scope.partReservation = angular.copy(initialPartReservation)

#  $scope.delete = (saleItem) ->
#    saleItemsProvider.delete(saleItem)
#    i = $scope.saleItems.indexOf(saleItem)
#    $scope.saleItems.splice(i, 1) if i != -1

#  $scope.add = (saleItem, fromTable = true) ->
#    saleItem.offers = [offer] if offer
#    saleItem.orders = [order] if order
#    saleItem.deliveries = [delivery] if delivery
#    saleItem.invoices = [invoice] if invoice
#    saleItem.sale = sale
#    saleItem.state = 'New'
#    saleItemsProvider.save(
#      saleItem,
#      (newSaleItem) ->
#        $scope.errors = null
#        saleItem.id = newSaleItem.id
#        watch(saleItem)
#        if fromTable
#          $scope.saleItems.push(angular.copy(initialProduct))
#        else
#          $scope.saleItems.splice($scope.saleItems.length - 1, 0, saleItem)
#
#      (res) ->
#        $scope.errors = res.data.details
#    )
).directive('partReservationsTable', () ->
  return {
    scope:{
      machine: '='
    }
    templateUrl: '/partials/app/partReservations/index.html'
    controller: 'awesomeCRM.partReservations.indexController'
  }
)
