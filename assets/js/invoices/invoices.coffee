angular.module('awesomeCRM.invoices', [
  'ui.router'
  'awesomeCRM.invoices.provider'
  'awesomeCRM.countries.provider'
  'awesomeCRM.comments.provider'
]).controller('awesomeCRM.invoices.formController', ($scope, $state, invoicesProvider, invoice, sale, $uibModalInstance) ->
  $scope.invoice = invoice
  $scope.sale = sale
  $scope.shown = true

  $scope.close = (invoice) ->
    if $uibModalInstance
      $uibModalInstance.close(invoice)
    else
      $state.go('invoices', null, {reload: true})

  $scope.save = () ->
    action = if invoice.id then 'update' else 'save'
    invoicesProvider[action](
      $scope.invoice,
      (invoice) -> $scope.close(invoice)
      (res) ->
        $scope.errors = res.data.details
        $scope.invoiceForm.$setPristine()
        $scope.invoiceForm.$setUntouched()
        for k,i of res.data.invalidAttributes
          $scope.invoiceForm[k].$setDirty(true);
          for j in i
            $scope.invoiceForm[k].$setValidity(j.rule, false);
    )
).controller('awesomeCRM.invoices.indexController', ($scope, $state, invoicesProvider, invoiceModal) ->
  sale = $scope.sale
  $scope.invoices = sale.invoices

  $scope.$watch(
    () -> try $scope.sale.invoices.length
    () -> invoicesProvider.query({sale: sale.id}, (invoices) -> $scope.invoices = invoices)
  )

  $scope.add = () ->
    invoice = angular.copy(sale.invoices.find((o) -> o.active)) ? {}
    delete invoice.id
    invoice.active = true
    invoice.sale = sale

    invoiceModal(invoice, sale).result.then((invoice) ->
      for i in sale.invoices
        continue if !i.active
        i.active = false
        invoicesProvider.update(i)
      sale.invoices.push(invoice)
    )

  $scope.edit = (invoice) -> invoiceModal(invoice, sale)

  $scope.delete = (invoice) ->
    invoicesProvider.delete(id: invoice.id)
    i = $scope.invoices.indexOf(invoice)
    $scope.invoices.splice(i, 1) if i != -1

).directive('invoicesTable', () ->
  return {
    scope:{
      sale: '='
    }
    templateUrl: '/partials/app/invoices/index.html'
  }
).directive('invoiceForm', (invoicesProvider, saleItemsProvider, companiesProvider, $q) ->
  return {
    scope:{
      products: '='
      sale: '='
      onSaved: '='
    }
    templateUrl: '/partials/app/invoices/form.html'
    link: (scope, element, attrs) ->
      sale = scope.sale
      scope.invoice = {
        sale: sale
        state: 'Pending'
      }

      companiesProvider.get({id: sale.company.id}, (company) ->
        scope.invoice[i] = company[i] for i in ['address', 'city', 'country', 'zip']
        scope.invoice.person = company.contactPerson
        scope.invoice.vatEligible = !!company.vatId
      ) if sale.company

      scope.$watch('products', (newValue) ->
        scope.invoice.products = newValue
        scope.shown = !!newValue
      )

      scope.save = () ->
        invoicesProvider.save(scope.invoice, (invoice) ->
          scope.shown = false
          promises = []
          for i in scope.invoice.products
            promises.push(saleItemsProvider.update({id: i.id}, {state: 'Invoice'}).$promise)
          sale.invoices.push(invoice)
          $q.all(promises).then(scope.onSaved) if scope.onSaved
        )
  }
).directive('invoiceStateSelect', ['staticSelect', (staticSelect) ->
  return staticSelect({noneSelectedLabel: 'No State', items: ['Pending', 'Paid', 'Rejected']})
]).factory('invoiceModal', ['$uibModal', ($uibModal) ->
  return (invoice, sale) ->
    $uibModal.open(
      templateUrl: '/partials/app/invoices/form.html'
      controller: 'awesomeCRM.invoices.formController'
      size: 'lg'
      resolve:
        invoice: invoice
        sale: sale
    )
])
