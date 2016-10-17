angular.module('awesomeCRM.partReservations', [
  'ui.router'
  'awesomeCRM.partReservations.provider'
]).controller('awesomeCRM.partReservations.indexController', ($uibModal, $scope, formErrorHandler, partReservationsProvider, partsProvider) ->
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
    partReservationsProvider.save($scope.partReservation, (partReservation) ->
      $scope.partReservations.push(partReservation)
    )
    $scope.partReservation = angular.copy(initialPartReservation)

  reserve = (partReservation, part) ->
    part.isAvailable = false
    partReservationsProvider.update({id: partReservation.id}, {part: part}, () ->
      partReservation.part = part
    )

  $scope.reserveByCode = (partReservation) ->
    $uibModal.open(
      templateUrl: '/partials/app/partReservations/barcode.html'
      controller: ($scope, $uibModalInstance) ->
        $scope.close = () ->
          $uibModalInstance.close()

        $scope.save = (data) ->
          partsProvider.query({barcode: data.barcode, isAvailable: true, type: partReservation.partType.id, limit: 1}, (parts) ->
            if parts and parts.length
              $uibModalInstance.close(parts[0])
            else
              $scope.errors = "No available parts found"
          )

      size: 'lg'
    ).result.then((part) ->
      return if !part

      reserve(partReservation, part)
    )

  $scope.reserveAny = (partReservation) ->
    partsProvider.query({isAvailable: true, type: partReservation.partType.id, limit: 1}, (parts) ->
      if parts and parts.length
        reserve(partReservation, parts[0])
    )

  $scope.reserveAll = () ->
    cnt = {}
    for i in $scope.partReservations
      cnt[i.partType.id] ?= []
      cnt[i.partType.id].push(i)

    for partType, partReservations of cnt
      do (partType, partReservations) ->
        partsProvider.query({isAvailable: true, type: partType, limit: partReservations.length}, (parts) ->
          if parts and parts.length
            for i,k in partReservations
              reserve(i, parts[k])
        )

  $scope.delete = (partReservation) ->
    partReservationsProvider.delete(id: partReservation.id)
    i = $scope.partReservations.indexOf(partReservation)
    $scope.partReservations.splice(i, 1) if i != -1
    partsProvider.update({id: partReservation.part.id}, {isAvailable: 0}) id partReservation.part

).directive('partReservationsTable', () ->
  return {
    scope:{
      machine: '='
    }
    templateUrl: '/partials/app/partReservations/index.html'
    controller: 'awesomeCRM.partReservations.indexController'
  }
)
