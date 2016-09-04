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
          size: 'lg'
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
).controller('awesomeCRM.productTemplates.formController', ($scope, debounce, $state, partTypeItemsProvider, productTemplatesProvider, productTemplate, $uibModalInstance) ->
  $scope.productTemplate = productTemplate

  watch = (pti) ->
    $scope.$watch(
      () -> JSON.stringify(pti)
      debounce(1000, (newValue, oldValue) ->
        return if newValue == oldValue
        partTypeItemsProvider.update(pti)
      )
    )

  productTemplate.$promise.then(() ->
    watch(i) for i in productTemplate.partTypeItems
    productTemplate.partTypeItems.push(count: 1)
  ) if productTemplate and productTemplate.$promise

  $scope.close = () ->
    if $uibModalInstance
      $uibModalInstance.close()
    else
      $state.go('productTemplates', null, {reload: true})

  $scope.save = () ->
    action = if productTemplate.id then 'update' else 'save'
    productTemplatesProvider[action](
      $scope.productTemplate,
      (productTemplate) ->
        if action == 'save' and !$uibModalInstance
          $state.go('productTemplates.edit', {id: productTemplate.id}, {reload: true})
        else
          $scope.close()
      (res) ->
        $scope.errors = res.data.details
        $scope.productTemplateForm.$setPristine()
        $scope.productTemplateForm.$setUntouched()
        for k,i of res.data.invalidAttributes
          $scope.productTemplateForm[k].$setDirty(true);
          for j in i
            $scope.productTemplateForm[k].$setValidity(j.rule, false);
    )

  $scope.addPartTypeItem = (pti) ->
    partTypeItemsProvider.save(
      pti,
      (newPti) ->
        $scope.errors = null
        pti.id = newPti.id
        watch(pti)
        productTemplate.partTypeItems.push(count: 1)
        productTemplatesProvider.addPartTypeItem(id: productTemplate.id, partTypeItemId: pti.id)

      (res) ->
        $scope.errors = res.data.details
    )

).directive('productTemplateSelect', ['productTemplatesProvider', 'dynamicSelect', (productTemplatesProvider, dynamicSelect) ->
  return dynamicSelect(productTemplatesProvider, 'productTemplates', {noneSelectedLabel: 'No Product Template'})
])
