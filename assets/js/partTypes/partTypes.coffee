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
    resolve:
      partType: () -> {}
    controller: 'awesomeCRM.partTypes.formController'
  )

  # Update page
  $stateProvider.state('partTypes.edit',
    url: '/edit/{id}'
    templateUrl: '/partials/app/partTypes/form.html'
    resolve:
      partType: (partTypesProvider, $stateParams) -> partTypesProvider.get(id: $stateParams.id)
    controller: 'awesomeCRM.partTypes.formController'
  )
).controller('awesomeCRM.partTypes.formController', ($scope, $state, partTypesProvider, partType) ->
  $scope.partType = partType

  $scope.types = []
  $scope.subtypes = []
  partTypesProvider.query().$promise.then((partTypes) ->
    for i in partTypes
      $scope.types.push(i.type) if i.type
      $scope.subtypes.push(i.subtype) if i.subtype
  )

  $scope.save = () ->
    action = if partType.id then 'update' else 'save'
    partTypesProvider[action](
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
