angular.module('awesomeCRM.auth.provider', [])
.factory('authProvider', ($location, $http) ->
  "ngInject"

  loggedIn = false

  $http.get('/user').then(() ->
    loggedIn = true
  )

  return {
    login: (credentials) ->
      $http.post('/auth/local', credentials).then(() ->
        loggedIn = true
        $location.path('/')
      )

    logout: () ->
      $http.get('/logout').then(() ->
        loggedIn = false
        $location.path('/')
      )

    loggedIn: () -> loggedIn
  }
)
