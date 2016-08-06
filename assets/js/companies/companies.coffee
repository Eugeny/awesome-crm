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

      $scope.delete = (company) ->
        companiesProvider.delete(company)
        i = $scope.companies.indexOf(company)
        $scope.companies.splice(i, 1) if i != -1

      $scope.groupMinSortField = (group) ->
        return $filter('min')($filter('map')(group, $scope.filters.sortField ? 'id'));
  )

  # Create page
  $stateProvider.state('companies.create',
    url: '/create'
    templateUrl: '/partials/app/companies/form.html'
    controller: ($scope, $state, companiesProvider) ->
      $scope.company = {}
      $scope.companyTypes = companyTypes

      $scope.save = () ->
        companiesProvider.save(
          $scope.company,
          (company) -> $state.go('companies.edit', {id: company.id}, {reload: true})
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

    controller: ($scope, $state, company, companiesProvider, commentsProvider, Upload, $timeout, $uibModal) ->
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

      $scope.uploadingProgress = -1
      $scope.uploadFiles = (files, errFiles) ->
        $scope.uploadingProgress = 0
        Upload.upload(
          url: '/filey/upload'
          arrayKey: '' # this is some weird piece of hack
          data:
            files: files
        ).then(
          (response) ->
            $scope.uploadingProgress = -1
            $scope.comment.files ?= []
            $scope.comment.files = $scope.comment.files.concat(response.data)
          ,
          (response) ->
            if response.status > 0
              $scope.uploadingError = response.status + ': ' + response.data
          ,
          (evt) ->
            $scope.uploadingProgress = Math.min(100, parseInt(100.0 * evt.loaded / evt.total))
        )

      $scope.save = () ->
        companiesProvider.update($scope.company, () -> $state.go('companies', null, {reload: true}))

      $scope.addPerson = () ->
        $uibModal.open(
          size: 'lg'
          templateUrl: '/partials/app/people/form.html'
          controller: 'awesomeCRM.people.formController'
          resolve:
            person:
              company: $scope.company
        ).result.then((person) ->
          return if !person
          $scope.company.people ?= []
          $scope.company.people.push(person)
        )

  )
);
