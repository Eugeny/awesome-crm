angular.module('awesomeCRM.machines', [
  'ui.router'
  'awesomeCRM.machines.provider'
]).config(($stateProvider, $urlRouterProvider) ->
  $stateProvider.state('machines',
    url: '/machines'
    templateUrl: '/partials/app/machines/index.html'
    resolve:
      machines: (machinesProvider) -> machinesProvider.query()

    controller: ($scope, $state, machines, machinesProvider, $uibModal) ->
      $scope.machines = machines
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
  return staticSelect({noneSelectedLabel: 'No Type', label: 'Type', items: ['type 1', 'type 2', 'type 3']})
]).directive('machineServiceLevelSelect', ['staticSelect', (staticSelect) ->
  return staticSelect({noneSelectedLabel: 'No Service Level', label: 'Service Level', items: ['serviceLevel 1', 'serviceLevel 2', 'serviceLevel 3']})
]).directive('machineSelect', ['machineProvider', 'dynamicSelect', (machineProvider, dynamicSelect) ->
  return dynamicSelect(machineProvider, 'machines', {noneSelectedLabel: 'No Machine', label: 'Machine'})
])
