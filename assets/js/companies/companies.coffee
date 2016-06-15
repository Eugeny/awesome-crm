angular.module('awesomeCRM.companies', [
  'ui.router'
  'awesomeCRM.companies.provider'
  'awesomeCRM.countries.provider'
  'awesomeCRM.comments.provider'
]).config(($stateProvider, $urlRouterProvider) ->
  $stateProvider.state('companies',
    url: '/companies'
    templateUrl: '/partials/app/companies/index.html'
    resolve:
      companies: (companiesProvider) ->
        companiesProvider.query()

    controller: ($scope, $state, companies, companiesProvider) ->
      $scope.companies = companies
      $scope.delete = (contact, k = -1) ->
        companiesProvider.delete(contact)
        $scope.companies.splice(k, 1) if k != -1
  )

  # Create page
  $stateProvider.state('companies.create',
    url: '/create'
    templateUrl: '/partials/app/companies/form.html'
    controller: ($scope, $state, companiesProvider, countriesProvider) ->
      $scope.company = {}
      $scope.countries = countriesProvider.countryNames

      $scope.save = () ->
        companiesProvider.save($scope.company, () -> $state.go('companies', null, {reload: true}))
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
