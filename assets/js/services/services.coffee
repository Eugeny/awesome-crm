angular.module('awesomeCRM.services', [
  'awesomeCRM.companies.provider'
  'awesomeCRM.partTypes.provider'
]).filter('bytes', () ->
  return (bytes, precision = 1) ->
    return '-' if (isNaN(parseFloat(bytes)) || !isFinite(bytes))
    units = ['bytes', 'kB', 'MB', 'GB', 'TB', 'PB']
    number = Math.floor(Math.log(bytes) / Math.log(1024));

    return (bytes / Math.pow(1024, Math.floor(number))).toFixed(precision) +  ' ' + units[number];
).directive('file', () ->
  return {
    scope:{
      file: '='
    }
    templateUrl: '/partials/app/misc/file.html'
  }
).directive('companySelect', ['$state', 'companiesProvider', ($state, companiesProvider) ->
  return {
    scope:
      label: '@'
      noneSelectedLabel: '@'
      model: '='
    templateUrl: '/partials/app/misc/dynamicSelect.html'
    link: (scope, element, attrs) ->
      companiesProvider.query((companies) ->
        scope.items = companies
      )
      scope.edit = (params) ->
        $state.go('companies.edit', params)

      scope.noneSelectedLabel ?= 'No Company'

  }
]).directive('partTypeSelect', ['$state', 'partTypesProvider', '$timeout', ($state, partTypesProvider, $timeout) ->
  return {
    scope:
      label: '@'
      model: '='
      multiple: '@'
    templateUrl: '/partials/app/misc/dynamicSelect.html'
    link: (scope, element, attrs) ->
      partTypesProvider.query((partTypes) ->
        scope.items = partTypes
      )
      scope.edit = (params) ->
        $state.go('partTypes.edit', params)

      scope.noneSelectedLabel ?= 'No Type'

      scope.select = {value: scope.model}
      scope.$watch(
        () -> JSON.stringify(scope.select)
        (newValue, oldValue) -> scope.model = scope.select.value if newValue != oldValue
      )

      # dirty-dirty fix because formstamp hardcodes placeholder - TODO submit a PR
      $timeout(
        () -> $(element).find('input').attr('placeholder', scope.multiple)
        100
      )
  }
])

