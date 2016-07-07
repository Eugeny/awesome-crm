angular.module('awesomeCRM.parts', [
  'ui.router'
  'awesomeCRM.parts.provider'
  'awesomeCRM.countries.provider'
  'awesomeCRM.comments.provider'
]).config(($stateProvider, $urlRouterProvider) ->
  $stateProvider.state('parts',
    url: '/parts'
    templateUrl: '/partials/app/parts/index.html'
    resolve:
      parts: (partsProvider) -> partsProvider.query()

    controller: ($scope, $state, parts, partsProvider) ->
      $scope.parts = parts
      $scope.filters = {}

      $scope.delete = (part) ->
        partsProvider.delete(part)
        i = $scope.parts.indexOf(part)
        $scope.parts.splice(i, 1) if i != -1
  )

  # Create page
  $stateProvider.state('parts.create',
    url: '/create'
    templateUrl: '/partials/app/parts/form.html'
    controller: ($scope, $state, partsProvider, countriesProvider) ->
      $scope.part = {}

      $scope.save = () ->
        partsProvider.save(
          $scope.part,
          () -> $state.go('parts', null, {reload: true})
          (res) ->
            $scope.errors = res.data.details
            $scope.partForm.$setPristine()
            $scope.partForm.$setUntouched()
            for k,i of res.data.invalidAttributes
              $scope.partForm[k].$setDirty(true);
              for j in i
                $scope.partForm[k].$setValidity(j.rule, false);
        )
  )

  # Update page
  $stateProvider.state('parts.edit',
    url: '/edit/{id}'
    templateUrl: '/partials/app/parts/form.html'
    resolve:
      part: (partsProvider, $stateParams) -> partsProvider.get(id: $stateParams.id)

    controller: ($scope, $state, part, partsProvider) ->
      $scope.part = part

      $scope.save = () ->
        partsProvider.update($scope.part, () -> $state.go('parts', null, {reload: true}))
  )
);
