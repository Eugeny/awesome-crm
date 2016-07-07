angular.module('awesomeCRM.partTypes', [
  'ui.router'
  'awesomeCRM.partTypes.provider'
  'awesomeCRM.countries.provider'
  'awesomeCRM.comments.provider'
]).config(($stateProvider, $urlRouterProvider) ->
  $stateProvider.state('partTypes',
    url: '/partTypes'
    templateUrl: '/partials/app/partTypes/index.html'
    resolve:
      partTypes: (partTypesProvider) -> partTypesProvider.query()

    controller: ($scope, $state, partTypes, partTypesProvider) ->
      $scope.partTypes = partTypes
      $scope.filters = {}

      $scope.delete = (partType) ->
        partTypesProvider.delete(partType)
        i = $scope.partTypes.indexOf(partType)
        $scope.partTypes.splice(i, 1) if i != -1
  )

  # Create page
  $stateProvider.state('partTypes.create',
    url: '/create'
    templateUrl: '/partials/app/partTypes/form.html'
    controller: ($scope, $state, partTypesProvider, countriesProvider) ->
      $scope.partType = {}

      $scope.save = () ->
        partTypesProvider.save(
          $scope.partType,
          () -> $state.go('partTypes', null, {reload: true})
          (res) ->
            $scope.errors = res.data.details
            $scope.partTypeForm.$setPristine()
            $scope.partTypeForm.$setUntouched()
            for k,i of res.data.invalidAttributes
              $scope.partTypeForm[k].$setDirty(true);
              for j in i
                $scope.partTypeForm[k].$setValidity(j.rule, false);
        )
  )

  # Update page
  $stateProvider.state('partTypes.edit',
    url: '/edit/{id}'
    templateUrl: '/partials/app/partTypes/form.html'
    resolve:
      partType: (partTypesProvider, $stateParams) -> partTypesProvider.get(id: $stateParams.id)

    controller: ($scope, $state, partType, partTypesProvider) ->
      $scope.partType = partType

      $scope.save = () ->
        partTypesProvider.update($scope.partType, () -> $state.go('partTypes', null, {reload: true}))
  )
);
