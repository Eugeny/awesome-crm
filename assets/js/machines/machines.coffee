angular.module('awesomeCRM.machines', [
  'ui.router'
  'awesomeCRM.machines.provider'
]).config(($stateProvider, $urlRouterProvider) ->
  $stateProvider.state('machines',
    url: '/machines'
    templateUrl: '/partials/app/machines/index.html'
    controller: 'awesomeCRM.machines.indexController'
  )

  # Create page
  $stateProvider.state('machines.create',
    url: '/create'
    templateUrl: '/partials/app/machines/form.html'
    resolve:
      machine: () -> {}
      $uibModalInstance: () -> null
    controller: 'awesomeCRM.machines.formController'
  )

  # Update page
  $stateProvider.state('machines.edit',
    url: '/edit/{id}'
    templateUrl: '/partials/app/machines/form.html'
    resolve:
      machine: (machinesProvider, $stateParams) -> machinesProvider.get(id: $stateParams.id)
      $uibModalInstance: () -> null
    controller: 'awesomeCRM.machines.formController'
  )
).controller('awesomeCRM.machines.indexController', ($scope, $state, machinesProvider, $uibModal) ->
  criteria = {}
  criteria.sale = $scope.sale.id ? $scope.sale if $scope.sale
  machinesProvider.query(criteria, (machines) -> $scope.machines = machines)

  $scope.filters = {}

  $scope.delete = (machine) ->
    machinesProvider.delete(id: machine.id)
    i = $scope.machines.indexOf(machine)
    $scope.machines.splice(i, 1) if i != -1

  $scope.add = () ->
    $uibModal.open(
      templateUrl: '/partials/app/machines/form.html'
      controller: 'awesomeCRM.machines.formController'
      resolve:
        machine: {}
    ).result.then((machine) ->
      return if !machine
      $scope.machines.push(machine)
    )
).controller('awesomeCRM.machines.formController', ($scope, $state, machinesProvider, machine, $uibModalInstance) ->
  $scope.machine = machine

  $scope.close = () ->
    if $uibModalInstance
      $uibModalInstance.close($scope.machine)
    else
      $state.go('machines', null, {reload: true})


  $scope.delete = (machine) ->
    machinesProvider.delete(id: machine.id)
    i = $scope.machines.indexOf(machine)
    $scope.machines.splice(i, 1) if i != -1
    $scope.close()

  $scope.save = () ->
    action = if machine.id then 'update' else 'save'
    machinesProvider[action](
      $scope.machine,
      () -> $scope.close()
      (res) ->
        $scope.errors = res.data.details
        $scope.machineForm.$setPristine()
        $scope.machineForm.$setUntouched()
        for k,i of res.data.invalidAttributes
          $scope.machineForm[k].$setDirty(true);
          for j in i
            $scope.machineForm[k].$setValidity(j.rule, false);
    )
).directive('machineStateSelect', ['staticSelect', (staticSelect) ->
  return staticSelect({noneSelectedLabel: 'No State', label: 'State', items: ['building', 'built', 'shipped']})
]).directive('machineTypeSelect', ['staticSelect', (staticSelect) ->
  return staticSelect({noneSelectedLabel: 'No Type', label: 'Type', items: [
    'ELEMENTS ONE'
    'ELEMENTS NAS'
    'ELEMENTS SAN'
    'ELEMENTS ARCHIVE'
    'ELEMENTS GRID'
    'ELEMENTS CUBE'
  ]})
]).directive('machineBackplaneSelect', ['staticSelect', (staticSelect) ->
  return staticSelect(label: 'Backplane', noneSelectedLabel: 'No Backplane', items: ['Single Port', 'Expander'])
]).directive('machineChassisSelect', ['staticSelect', (staticSelect) ->
  return staticSelect(label: 'Chassis', noneSelectedLabel: 'No Chassis', items: ['1.0 - 2012', '2.0 - 11/2013', '3.0 - 04/2014', '4.0 - 2015'])
]).directive('machineServiceLevelSelect', ['staticSelect', (staticSelect) ->
  return staticSelect(label: 'Service Level', noneSelectedLabel: 'No Service Level', items: ['Silver', 'Gold'])
]).directive('machineSelect', ['machinesProvider', 'dynamicSelect', (machinesProvider, dynamicSelect) ->
  return dynamicSelect(machinesProvider, 'machines', {noneSelectedLabel: 'No Machine', label: 'Machine'})
]).directive('machinesTable', () ->
  return {
    scope:{
      sale: '='
    }
    link: (scope, elements, attrs) ->
      scope.hideFilters = 'true'
    controller: 'awesomeCRM.machines.indexController'
    templateUrl: '/partials/app/machines/index.html'
  }
).directive('machineConfigurator', () ->
  return {
    templateUrl: '/partials/app/machines/configurator.html'
    scope:
      machine: '='
    link: (scope, elements, attrs) ->
      scope._ = {}

      scope.clone = (a, e) =>
        e = angular.extend({}, e)
        e.id += 1
        for ee in a
          if ee.id >= e.id
            e.id = ee.id + 1
        a.push(e)

      scope.$watch(
        () -> scope.machine.config
        () ->
          scope.machine.config ?= {}
          scope.machine.config.mb ?= {}
          scope.machine.config.cpus ?= []
          scope.machine.config.coolers ?= []
          scope.machine.config.ssds ?= []
          scope.machine.config.hdds ?= []
          scope.machine.config.jbods ?= []
          scope.machine.config.ram ?= []
          scope.machine.config.raids ?= []
          scope.machine.config.ifaces ?= []
          scope.machine.config.int_ifaces ?= []
        true
      )

      scope.pasteHDDs = (target) ->
        for line in scope._.pastedTable.split('\n')
          tokens = line.split('\t')
          if tokens[0] == 'Position'
            continue
          target.push {
            id: parseInt(tokens[0])
            iface: tokens[1]
            capacity: tokens[2]
            rpm: tokens[3]
            manufacturer: tokens[4]
            sn: tokens[5]
          }
        scope._.pastedTable = ''
  }
)
