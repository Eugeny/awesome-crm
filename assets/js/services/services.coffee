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
).factory('dynamicSelect', ['$state', '$timeout', ($state, $timeout) ->
  return (provider, editModule = null, defaultScope = {}) -> {
    scope:
      label: '@'
      noneSelectedLabel: '@'
      model: '='
      multiple: '@'
    templateUrl: '/partials/app/misc/dynamicSelect.html'
    link: (scope, element, attrs) ->
      provider.query((items) ->
        i.name = defaultScope.labelFn(i) for i in items if defaultScope.labelFn
        scope.items = items
      ) if provider

      if editModule
        scope.edit = (params) -> $state.go("#{editModule}.edit", params)

      scope[k] ?= i for k,i of defaultScope

      scope.select = {value: scope.model}
      scope.$watch(
        () -> JSON.stringify(scope.select)
        (newValue, oldValue) ->
          if newValue != oldValue
            scope.model = scope.select.value

          # for select value to match db value
          try scope.model.name = defaultScope.labelFn(scope.model)  if defaultScope.labelFn
      )
      scope.$watch(
        () -> JSON.stringify(scope.model)
        (newValue, oldValue) ->
          if newValue != oldValue
            scope.select.value = scope.model
      )

      # dirty-dirty fix because formstamp hardcodes placeholder - TODO submit a PR
      $timeout(
        () -> $(element).find('input').attr('placeholder', scope.multiple)
        100
      )
  }
]).factory('staticSelect', ['$state', '$timeout', ($state, $timeout) ->
  return (defaultScope = {}) -> {
    scope:
      label: '@'
      noneSelectedLabel: '@'
      model: '='
      multiple: '@'
      ngDisabled: '='
    templateUrl: '/partials/app/misc/staticSelect.html'
    link: (scope, element, attrs) ->
      scope[k] ?= i for k,i of defaultScope

      scope.select = {value: scope.model}
      scope.$watch(
        () -> JSON.stringify(scope.select)
        (newValue, oldValue) ->
          if newValue != oldValue
            scope.model = scope.select.value
      )
      scope.$watch(
        () -> JSON.stringify(scope.model)
        (newValue, oldValue) ->
          if newValue != oldValue
            scope.select.value = scope.model
      )

      # dirty-dirty fix because formstamp hardcodes placeholder - TODO submit a PR
      $timeout(
        () -> $(element).find('input').attr('placeholder', scope.multiple)
        100
      )
  }
]).directive('companySelect', ['companiesProvider', 'dynamicSelect', (companiesProvider, dynamicSelect) ->
  return dynamicSelect(companiesProvider, 'companies', {noneSelectedLabel: 'No Company'})
]).directive('personSelect', ['peopleProvider', 'dynamicSelect', (peopleProvider, dynamicSelect) ->
  return dynamicSelect(peopleProvider, 'people', {noneSelectedLabel: 'No Person', labelFn: (p) -> "#{p.firstName} #{p.lastName}"})
]).directive('partTypeSelect', ['partTypesProvider', 'dynamicSelect', (partTypesProvider, dynamicSelect) ->
  return dynamicSelect(partTypesProvider, 'partTypes', {noneSelectedLabel: 'No Type'})
]).directive('currencySelect', ['staticSelect', (staticSelect) ->
  return staticSelect({noneSelectedLabel: 'No Type', items: ['€', 'USD']})
]).factory('debounce', ($timeout) ->
  (interval, callback) ->
    timeout = null
    return () ->
      args = arguments
      $timeout.cancel(timeout)
      timeout = $timeout((->
        callback.apply(this, args)
      ), interval)
)

