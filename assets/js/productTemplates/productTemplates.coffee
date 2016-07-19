angular.module('awesomeCRM.productTemplates', [
  'ui.router'
  'awesomeCRM.productTemplates.provider'
  'awesomeCRM.countries.provider'
  'awesomeCRM.comments.provider'
]).config(($stateProvider, $urlRouterProvider) ->
  $stateProvider.state('productTemplates',
    url: '/productTemplates'
    templateUrl: '/partials/app/productTemplates/index.html'
    resolve:
      productTemplates: (productTemplatesProvider) -> productTemplatesProvider.query()

    controller: ($scope, $state, productTemplates, productTemplatesProvider) ->
      $scope.productTemplates = productTemplates
      $scope.filters = {}

      $scope.delete = (productTemplate) ->
        productTemplatesProvider.delete(productTemplate)
        i = $scope.productTemplates.indexOf(productTemplate)
        $scope.productTemplates.splice(i, 1) if i != -1

      $scope.add = () ->
        $uibModal.open(
          templateUrl: '/partials/app/productTemplates/form.html'
          controller: 'awesomeCRM.productTemplates.formController'
        )
  )

  # Create page
  $stateProvider.state('productTemplates.create',
    url: '/create'
    templateUrl: '/partials/app/productTemplates/form.html'
    resolve:
      productTemplate: () -> {}
      $uibModalInstance: () -> null
    controller: 'awesomeCRM.productTemplates.formController'
  )

  # Update page
  $stateProvider.state('productTemplates.edit',
    url: '/edit/{id}'
    templateUrl: '/partials/app/productTemplates/form.html'
    resolve:
      productTemplate: (productTemplatesProvider, $stateParams) -> productTemplatesProvider.get(id: $stateParams.id)
      $uibModalInstance: () -> null
    controller: 'awesomeCRM.productTemplates.formController'
  )
).controller('awesomeCRM.productTemplates.formController', ($scope, $state, productTemplatesProvider, productTemplate, $uibModalInstance) ->
  $scope.productTemplate = productTemplate

  $scope.close = () ->
    if $uibModalInstance
      $uibModalInstance.close()
    else
      $state.go('productTemplates', null, {reload: true})

  $scope.save = () ->
    action = if productTemplate.id then 'update' else 'save'
    productTemplatesProvider[action](
      $scope.productTemplate,
      () -> $scope.close()
      (res) ->
        $scope.errors = res.data.details
        $scope.productTemplateForm.$setPristine()
        $scope.productTemplateForm.$setUntouched()
        for k,i of res.data.invalidAttributes
          $scope.productTemplateForm[k].$setDirty(true);
          for j in i
            $scope.productTemplateForm[k].$setValidity(j.rule, false);
    )
)
