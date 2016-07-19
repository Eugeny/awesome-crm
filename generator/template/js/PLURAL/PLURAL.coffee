angular.module('awesomeCRM.PLURAL', [
  'ui.router'
  'awesomeCRM.PLURAL.provider'
  'awesomeCRM.countries.provider'
  'awesomeCRM.comments.provider'
]).config(($stateProvider, $urlRouterProvider) ->
  $stateProvider.state('PLURAL',
    url: '/PLURAL'
    templateUrl: '/partials/app/PLURAL/index.html'
    resolve:
      PLURAL: (PLURALProvider) -> PLURALProvider.query()

    controller: ($scope, $state, PLURAL, PLURALProvider, $uibModal) ->
      $scope.PLURAL = PLURAL
      $scope.filters = {}

      $scope.delete = (SINGULAR) ->
        PLURALProvider.delete(SINGULAR)
        i = $scope.PLURAL.indexOf(SINGULAR)
        $scope.PLURAL.splice(i, 1) if i != -1

      $scope.add = () ->
        $uibModal.open(
          templateUrl: '/partials/app/PLURAL/form.html'
          controller: 'awesomeCRM.PLURAL.formController'
          resolve:
            SINGULAR: {}
        ).result.then((SINGULAR) ->
          $scope.PLURAL.push(SINGULAR)
        )
  )

  # Create page
  $stateProvider.state('PLURAL.create',
    url: '/create'
    templateUrl: '/partials/app/PLURAL/form.html'
    resolve:
      SINGULAR: () -> {}
      $uibModalInstance: () -> null
    controller: 'awesomeCRM.PLURAL.formController'
  )

  # Update page
  $stateProvider.state('PLURAL.edit',
    url: '/edit/{id}'
    templateUrl: '/partials/app/PLURAL/form.html'
    resolve:
      SINGULAR: (PLURALProvider, $stateParams) -> PLURALProvider.get(id: $stateParams.id)
      $uibModalInstance: () -> null
    controller: 'awesomeCRM.PLURAL.formController'
  )
).controller('awesomeCRM.PLURAL.formController', ($scope, $state, PLURALProvider, SINGULAR, $uibModalInstance) ->
  $scope.SINGULAR = SINGULAR

  $scope.close = () ->
    if $uibModalInstance
      $uibModalInstance.close($scope.SINGULAR)
    else
      $state.go('PLURAL', null, {reload: true})

  $scope.save = () ->
    action = if SINGULAR.id then 'update' else 'save'
    PLURALProvider[action](
      $scope.SINGULAR,
      () -> $scope.close()
      (res) ->
        $scope.errors = res.data.details
        $scope.SINGULARForm.$setPristine()
        $scope.SINGULARForm.$setUntouched()
        for k,i of res.data.invalidAttributes
          $scope.SINGULARForm[k].$setDirty(true);
          for j in i
            $scope.SINGULARForm[k].$setValidity(j.rule, false);
    )
)
