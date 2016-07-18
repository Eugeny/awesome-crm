angular.module('awesomeCRM.people', [
  'ui.router'
  'awesomeCRM.people.provider'
  'awesomeCRM.countries.provider'
  'awesomeCRM.comments.provider'
]).config(($stateProvider, $urlRouterProvider) ->
  cookiePrefix = 'awesomeCRM.people'

  $stateProvider.state('people',
    url: '/people'
    templateUrl: '/partials/app/people/index.html'
    resolve:
      people: (peopleProvider) -> peopleProvider.query()

    controller: ($scope, $state, people, peopleProvider, $cookies) ->
      $scope.people = people
      $scope.filters = {
        groupField:
          key: 'alph'
        reverseName: $cookies.getObject("#{cookiePrefix}.reverseName")
      }
      $scope.groupHidden = {}

      $scope.resetFilters = () ->
        for k of $scope.filters
          delete $scope.filters[k]

      $scope.$watch('filter.groupField.key', () ->
        $scope.groupHidden = {}
      )

      updateAlphField = () ->
        for i in $scope.people
          try
            i.alph = (if $scope.filters.reverseName then i.lastName else i.firstName)[0]
      $scope.$watch((() -> if $scope.people then $scope.people.length else 0), updateAlphField)
      $scope.$watch('filters.reverseName', () ->
        $cookies.putObject("#{cookiePrefix}.reverseName", $scope.filters.reverseName)
        updateAlphField()
      )

      $scope.delete = (person) ->
        peopleProvider.delete(person)
        i = $scope.people.indexOf(person)
        $scope.people.splice(i, 1) if i != -1

      $scope.groupMinSortField = (group) ->
        return group[0].alph
  )

  # Create page
  $stateProvider.state('people.create',
    url: '/create'
    templateUrl: '/partials/app/people/form.html'
    controller: ($scope, $state, peopleProvider, countriesProvider) ->
      $scope.person = {}
      $scope.countries = countriesProvider.countryNames

      $scope.save = () ->
        peopleProvider.save(
          $scope.person,
          () -> $state.go('people', null, {reload: true})
          (res) ->
            $scope.errors = res.data.details
            $scope.personForm.$setPristine()
            $scope.personForm.$setUntouched()
            for k,i of res.data.invalidAttributes
              $scope.personForm[k].$setDirty(true);
              for j in i
                $scope.personForm[k].$setValidity(j.rule, false);
        )
  )

  # Update page
  $stateProvider.state('people.edit',
    url: '/edit/{id}'
    templateUrl: '/partials/app/people/form.html'
    resolve:
      person: (peopleProvider, $stateParams) -> peopleProvider.get(id: $stateParams.id)

    controller: ($scope, $state, person, peopleProvider, commentsProvider, Upload, countriesProvider) ->
      $scope.person = person
      $scope.comment = {}
      $scope.countries = countriesProvider.countryNames

      $scope.addComment = () ->
        $scope.comment.person = person.id
        commentsProvider.save($scope.comment, (comment) ->
          person.comments ?= []
          person.comments.push(comment)
          peopleProvider.addComment({id: person.id, commentId: comment.id})
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
        peopleProvider.update($scope.person, () -> $state.go('people', null, {reload: true}))
  )
);
