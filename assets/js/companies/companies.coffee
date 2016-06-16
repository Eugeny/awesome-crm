angular.module('awesomeCRM.companies', [
  'ui.router'
  'awesomeCRM.companies.provider'
  'awesomeCRM.countries.provider'
  'awesomeCRM.comments.provider'
]).config(($stateProvider, $urlRouterProvider) ->
  companyTypes = [
    'End Customer'
    'Partner'
    'Potential Partner'
    'Supplier'
    'Marketing'
  ]
  companyTypeGroups = {
    'All Creditors': [
      'Supplier'
      'Marketing'
    ]
    'All Debitors': [
      'End Customer'
      'Partner'
      'Potential Partner'
      '' # empty type goes here
    ]
  }

  $stateProvider.state('companies',
    url: '/companies'
    templateUrl: '/partials/app/companies/index.html'
    resolve:
      companies: (companiesProvider) ->
        companiesProvider.query()

    controller: ($scope, $state, companies, companiesProvider, $filter) ->
      $scope.companies = companies
      $scope.filters = {}
      $scope.groupHidden = {}
      $scope.companyTypesFilter = []
      for k,i of companyTypeGroups
        $scope.companyTypesFilter.push(
          label: k
          value: i
        )
      for i in companyTypes
        $scope.companyTypesFilter.push(
          label: i
          value: i
        )

      $scope.customFilter = (x) ->
        return true if !$scope.filters.type
        if typeof $scope.filters.type.value == 'string'
          return x.type == $scope.filters.type.value
        else
          return $scope.filters.type.value.indexOf(x.type ? '') != -1
      $scope.resetFilters = () ->
        for k of $scope.filters
          delete $scope.filters[k]

      $scope.$watch('filter.groupField.key', () ->
        $scope.groupHidden = {}
      )
      $scope.$watch(
        () -> if $scope.companies then $scope.companies.length else 0
        () ->
          for i in $scope.companies
            try i.alph = i.name[0]
      )

      $scope.delete = (contact, k = -1) ->
        companiesProvider.delete(contact)
        $scope.companies.splice(k, 1) if k != -1

      $scope.groupMinSortField = (group) ->
        return $filter('min')($filter('map')(group, $scope.filters.sortField ? 'id'));
  )

  # Create page
  $stateProvider.state('companies.create',
    url: '/create'
    templateUrl: '/partials/app/companies/form.html'
    controller: ($scope, $state, companiesProvider, countriesProvider) ->
      $scope.company = {}
      $scope.countries = countriesProvider.countryNames
      $scope.companyTypes = companyTypes

      $scope.save = () ->
        companiesProvider.save(
          $scope.company,
          () -> $state.go('companies', null, {reload: true})
          (res) ->
            $scope.errors = res.data.details
            $scope.companyForm.$setPristine()
            $scope.companyForm.$setUntouched()
            for k,i of res.data.invalidAttributes
              $scope.companyForm[k].$setDirty(true);
              for j in i
                $scope.companyForm[k].$setValidity(j.rule, false);
        )
  )

  # Update page
  $stateProvider.state('companies.edit',
    url: '/edit/{id}'
    templateUrl: '/partials/app/companies/form.html'
    resolve:
      company: (companiesProvider, $stateParams) ->
        companiesProvider.get(id: $stateParams.id)

    controller: ($scope, $state, company, companiesProvider, commentsProvider) ->
      $scope.company = company
      $scope.comment = {}
      $scope.companyTypes = companyTypes

      $scope.addComment = () ->
        $scope.comment.company = company.id
        commentsProvider.save($scope.comment, (comment) ->
          company.comments.push(comment)
          companiesProvider.addComment({id: company.id, commentId: comment.id})
          $scope.comment = {}
        )

      $scope.save = () ->
        companiesProvider.update($scope.company, () -> $state.go('companies', null, {reload: true}))
  )
);
