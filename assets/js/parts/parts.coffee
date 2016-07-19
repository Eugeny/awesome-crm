angular.module('awesomeCRM.parts', [
  'ui.router'
  'awesomeCRM.parts.provider'
  'awesomeCRM.countries.provider'
  'awesomeCRM.comments.provider'
]).config(($stateProvider, $urlRouterProvider) ->
  $stateProvider.state('parts',
    url: '/parts'
    templateUrl: '/partials/app/parts/index.html'
    controller: ($scope, $state, partsProvider, $uibModal) ->
      $scope.filters = {
        types:[]
      }

      updatePartList = () ->
        criteria = {}

        if $scope.filters.barcode
          criteria.barcode =
            contains: $scope.filters.barcode

        if $scope.filters.types and $scope.filters.types.length
          criteria.type = $scope.filters.types.map((x) -> x.id)

        $scope.parts = partsProvider.query(where: criteria, limit: 100)

      $scope.$watch(
        () -> JSON.stringify($scope.filters)
        updatePartList
      )

      $scope.delete = (part) ->
        partsProvider.delete(part)
        i = $scope.parts.indexOf(part)
        $scope.parts.splice(i, 1) if i != -1

      $scope.add = () ->
        $uibModal.open(
          animation: $scope.animationsEnabled
          templateUrl: '/partials/app/parts/form.html'
          controller: 'awesomeCRM.parts.formController'
        )
  )

  # Create page
  $stateProvider.state('parts.create',
    url: '/create'
    templateUrl: '/partials/app/parts/form.html'
    controller: 'awesomeCRM.parts.formController'
    resolve:
      part: () -> {}
      $uibModalInstance: () -> null
  )

  # Update page
  $stateProvider.state('parts.edit',
    url: '/edit/{id}'
    templateUrl: '/partials/app/parts/form.html'
    resolve:
      part: (partsProvider, $stateParams) -> partsProvider.get(id: $stateParams.id)
      $uibModalInstance: () -> null
    controller: 'awesomeCRM.parts.formController'
  )
).controller('awesomeCRM.parts.formController', ($scope, $state, partsProvider, countriesProvider, $q, $uibModalInstance, part) ->
  $scope.part = part

  $scope.close = () ->
    if $uibModalInstance
      $uibModalInstance.close()
    else
      $state.go('parts', null, {reload: true})

  $scope.save = () ->
    promises = []

    barcodes = $scope.part.barcode.split(' ')

    for i in barcodes
      part = angular.copy($scope.part)
      part.barcode = i
      do (part) ->
        promises.push($q((resolve, reject) ->
          if part.id
            partsProvider.update(part, resolve, (res) ->
              reject({part: part, res: res})
            )
          else
            partsProvider.save(part, resolve, (res) ->
              reject({part: part, res: res})
            )
        ))

    $q.allSettled(promises).then(
      (res) ->
        rejected = res.filter((x) -> x.state == 'rejected').map((x) -> x.reason)
        if rejected.length
          $scope.partForm.$setPristine()
          $scope.partForm.$setUntouched()
          errorBarcodes = []
          $scope.errors = ''

          for i in rejected
            errorBarcodes.push(i.part.barcode)
            data = i.res.data
            $scope.errors += data.details + "\n"
            for k,i of data.invalidAttributes
              $scope.partForm[k].$setDirty(true);
              for j in i
                $scope.partForm[k].$setValidity(j.rule, false);

          $scope.part.barcode = errorBarcodes.join(' ')
        else
          $scope.close()
    )
)
