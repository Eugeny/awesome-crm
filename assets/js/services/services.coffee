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
      providerOptions: '='
    templateUrl: '/partials/app/misc/dynamicSelect.html'
    link: (scope, element, attrs) ->
      update = () ->
        provider.query(scope.providerOptions, (items) ->
          i.name = defaultScope.labelFn(i) for i in items if defaultScope.labelFn
          scope.items = items
        ) if provider
      update()

      scope.$watch(
        () -> JSON.stringify(scope.providerOptions)
        update
      )

      if editModule
        scope.edit = (params) -> $state.go("#{editModule}.edit", params)


      scope[k] ?= i for k,i of defaultScope

      scope.model ?= [] if scope.multiple
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

      scope.model ?= scope.defaultValue if scope.defaultValue
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
]).directive('countrySelect', ['countriesProvider', 'staticSelect', (countriesProvider, staticSelect) ->
  return staticSelect({label: 'Country', noneSelectedLabel: 'No Country', items: countriesProvider.countryNames})
]).directive('currencySelect', ['staticSelect', (staticSelect) ->
  return staticSelect(label: 'Currency', noneSelectedLabel: 'No Type', items: ['€', 'USD'], defaultValue: '€')
]).factory('debounce', ($timeout) ->
  (interval, callback) ->
    timeout = null
    return () ->
      args = arguments
      $timeout.cancel(timeout)
      timeout = $timeout((->
        callback.apply(this, args)
      ), interval)
).directive('checkbox', () ->
  scope:
    ngModel: '='
    label: '@'
  template: '<div class="checkbox"><label><input ng-model="ngModel" type="checkbox">{{label}}</label></div>'
).factory('formErrorHandler', () ->
  (form) ->
    (res) ->
      form.errorsText = res.data.details
      form.$setPristine()
      form.$setUntouched()
      for k,i of res.data.invalidAttributes
        form[k].$setDirty(true);
        for j in i
          form[k].$setValidity(j.rule, false);
).directive('bsActiveLink', ($location) ->
  restrict: 'A'
  replace: false
  link: (scope, elem) ->
    scope.$on('$stateChangeSuccess', ->
      hrefs = [
        '/#' + $location.path()
        '#' + $location.path()
        $location.path()
      ]

      angular.element(document.getElementById('sidebar-menu')).find('li').removeClass('active')
      activeSubmenus = [];

      angular.forEach(elem.find('a'), (a) ->
        a = angular.element(a)
        if -1 != hrefs.indexOf(a.attr('href'))
          a.parent().addClass('current-page')
          pp = a.parent().parent()
          activeSubmenus.push(pp.parent()) if pp.hasClass('nav')
        else
          a.parent().removeClass('current-page')
      )

      i.addClass('active') for i in activeSubmenus
    )
).directive('confirm', () ->
  priority: -1
  link: (scope, element, attrs) ->
    element.bind('click', (e) ->
      message = attrs.confirm
      if(message && !confirm(message))
        e.stopImmediatePropagation()
        e.preventDefault()
    )
)
