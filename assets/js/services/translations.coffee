angular.module('awesomeCRM.translations', []).config(($translateProvider) ->
  $translateProvider.translations('en',
    'DELETE_CONFIRMATION': 'Are you sure you want to delete {{title}}?'
  )
  $translateProvider.preferredLanguage('en')
)
