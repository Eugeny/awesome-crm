angular.module('awesomeCRM.sales', [
  'ui.router'
  'awesomeCRM.sales.provider'
  'awesomeCRM.countries.provider'
  'awesomeCRM.comments.provider'
]).config(($stateProvider, $urlRouterProvider) ->
  $stateProvider.state('sales',
    url: '/sales'
    templateUrl: '/partials/app/sales/index.html'
    resolve:
      sales: (salesProvider) -> salesProvider.query()

    controller: ($scope, $state, sales, salesProvider, $uibModal) ->
      $scope.sales = sales
      $scope.filters = {}

      $scope.delete = (sale) ->
        salesProvider.delete(sale)
        i = $scope.sales.indexOf(sale)
        $scope.sales.splice(i, 1) if i != -1

      $scope.add = () ->
        $uibModal.open(
          templateUrl: '/partials/app/sales/form.html'
          controller: 'awesomeCRM.sales.formController'
          resolve:
            sale: {}
        ).result.then((sale) ->
          $scope.sales.push(sale)
        )
  )

  # Create page
  $stateProvider.state('sales.create',
    url: '/create'
    templateUrl: '/partials/app/sales/form.html'
    resolve:
      sale: () -> {}
      $uibModalInstance: () -> null
    controller: 'awesomeCRM.sales.formController'
  )

  # Update page
  $stateProvider.state('sales.edit',
    url: '/edit/{id}'
    templateUrl: '/partials/app/sales/form.html'
    resolve:
      sale: (salesProvider, $stateParams) -> salesProvider.get(id: $stateParams.id)
      $uibModalInstance: () -> null
    controller: 'awesomeCRM.sales.formController'
  )
).controller('awesomeCRM.sales.formController', ($scope, $state, salesProvider, sale, $uibModalInstance, offersProvider) ->
  sale.state ?= 'Offer'
  $scope.sale = sale

  $scope.close = () ->
    if $uibModalInstance
      $uibModalInstance.close($scope.sale)
    else
      $state.go('sales', null, {reload: true})

  $scope.save = () ->
    action = if sale.id then 'update' else 'save'
    $scope.sale.offers = [{active: true}] if !$scope.sale.offers

    salesProvider[action](
      $scope.sale,
      () -> $scope.close() if $uibModalInstance
      (res) ->
        $scope.errors = res.data.details
        $scope.saleForm.$setPristine()
        $scope.saleForm.$setUntouched()
        for k,i of res.data.invalidAttributes
          $scope.saleForm[k].$setDirty(true);
          for j in i
            $scope.saleForm[k].$setValidity(j.rule, false);
    )

  $scope.delete = (sale) ->
    salesProvider.delete(sale)
    $scope.close()

  $scope.setState = (state) ->
    $scope.sale.state = state
    $scope.save()
)
