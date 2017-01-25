angular.module('awesomeCRM.people', [
  'ui.router'
  'awesomeCRM.people.provider'
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
        createdAt:
          startDate: null
          endDate: null
      }
      $scope.groupHidden = {}

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


      $scope.filterDateRangeOptions =
        ranges:
          'Today': [
            moment()
            moment()
          ]
          'Yesterday': [
            moment().subtract(1, 'days')
            moment().subtract(1, 'days')
          ]
          'Last 7 Days': [
            moment().subtract(6, 'days')
            moment()
          ]
          'Last 30 Days': [
            moment().subtract(29, 'days')
            moment()
          ]
          'This Month': [
            moment().startOf('month')
            moment()
          ]
          'Last Month': [
            moment().subtract(1, 'month').startOf('month')
            moment().subtract(1, 'month').endOf('month')
          ]
      $scope.filterDateRangeClearable = true
  )

  # Create page
  $stateProvider.state('people.create',
    url: '/create'
    templateUrl: '/partials/app/people/form.html'
    controller: 'awesomeCRM.people.formController'
    resolve:
      person: () -> {}
      $uibModalInstance: () -> null
  )

  # Update page
  $stateProvider.state('people.edit',
    url: '/edit/{id}'
    templateUrl: '/partials/app/people/form.html'
    resolve:
      person: (peopleProvider, $stateParams) -> peopleProvider.get(id: $stateParams.id)
      $uibModalInstance: () -> null
    controller: 'awesomeCRM.people.formController'
  )
).controller('awesomeCRM.people.formController', ($scope, $state, person, peopleProvider, commentsProvider, Upload, $uibModalInstance) ->
  $scope.person = person
  $scope.comment = {}

  $scope.close = (person) ->
    if $uibModalInstance
      $uibModalInstance.close(person)
    else
      if person
        $state.go('people.edit', {id: person.id}, {reload: true})
      else
        $state.go('people', null, {reload: true})

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
    action = if $scope.person.id then 'update' else 'save'
    peopleProvider[action](
      $scope.person,
      (person) -> $scope.close(person)
      (res) ->
        $scope.errors = res.data.details
        $scope.personForm.$setPristine()
        $scope.personForm.$setUntouched()
        for k,i of res.data.invalidAttributes
          $scope.personForm[k].$setDirty(true);
          for j in i
            $scope.personForm[k].$setValidity(j.rule, false);
    )
).directive('personSelect', ['peopleProvider', 'dynamicSelect', (peopleProvider, dynamicSelect) ->
  return dynamicSelect(peopleProvider, 'people', {noneSelectedLabel: 'No Person', labelFn: (p) -> "#{p.firstName} #{p.lastName}"})
]).filter('dateRangeFilter', ($filter) ->
  (items, field, range) ->
    $filter('filter')(items, (v) ->
      return true if !range.startDate and !range.endDate
      date = moment(v[field])
      return false if range.startDate and date < range.startDate
      return false if range.endDate and date > range.endDate
      return true
    )
).directive('personRelationSelect', ['staticSelect', (staticSelect) ->
  return staticSelect(label: 'Relation', noneSelectedLabel: 'No Relation', items: ['Touch', 'Lead', 'Qualified lead', 'Potential customer', 'Customer'])
]).directive('personTitleSelect', ['staticSelect', (staticSelect) ->
  return staticSelect(label: 'Title', noneSelectedLabel: 'No Title', items: ['Mr.', 'Mrs.', 'Ms.', 'Dr.', 'Prof.', 'Prof. Dr.', 'Dipl-Ing.'], freetext: true)
])
