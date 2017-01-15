angular.module('awesomeCRM.machines.provider', [])
.factory('machinesProvider', ($resource) ->
  "ngInject"

  return $resource('/machine/:id', {id: '@id'} , {
    update:
      method: 'PUT'
    query:
      method: 'GET'
      isArray: true
      transformResponse: (response) ->
        machines = JSON.parse(response)
        for i,k in machines
          for j in ['manufacturedOn', 'maintenanceStart', 'maintenanceEnd']
            machines[k][j] = new Date(i[j]) if i[j]
        return machines
    get:
      method: 'GET'
      isArray: false
      transformResponse: (response) ->
        machine = JSON.parse(response)
        for j in ['manufacturedOn', 'maintenanceStart', 'maintenanceEnd']
          machine[j] = new Date(machine[j]) if machine[j]
        console.log(machine)
        return machine
  })
)
