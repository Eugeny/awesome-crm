angular.module('awesomeCRM.productTemplates.provider', [])
.factory('productTemplatesProvider', ($resource) ->
  "ngInject"

  return $resource('/productTemplate/:id', {id: '@id'} , {
    update:
      method: 'PUT'

    addPartTypeItem:
      method: 'POST'
      url: '/productTemplate/:id/partTypeItems/:partTypeItemId'
      params:
        id: '@id'
        partTypeItemId: '@partTypeItemId'
  })
)
