angular.module('awesomeCRM.comments', [
]).directive('commentsList', (commentsProvider, Upload) ->
  return {
    scope:{
      company: '='
      sale: '='
      machine: '='
      person: '='
    }
    templateUrl: '/partials/app/comments/index.html'
    link: (scope, element, attrs) ->
      criteria = {}

      empty = true
      for i in ['company', 'person', 'machine', 'sale']
        if scope[i]
          criteria[i] = scope[i].id
          empty = false

      if empty
        throw 'comments-list directive requires company, machine, sale or person to be set in the scope'

      commentsProvider.query(criteria, (comments) ->
        scope.comments = comments
      )

      scope.comment = {}

      scope.addComment = () ->
        angular.extend(scope.comment, criteria)

        commentsProvider.save(scope.comment, (comment) ->
          scope.comments.push(scope.comment)
          scope.comment = {}
        )

      scope.uploadingProgress = -1
      scope.uploadFiles = (files, errFiles) ->
        scope.uploadingProgress = 0
        Upload.upload(
          url: '/filey/upload'
          arrayKey: '' # this is some weird piece of hack
          data:
            files: files
        ).then(
          (response) ->
            scope.uploadingProgress = -1
            scope.comment.files ?= []
            scope.comment.files = scope.comment.files.concat(response.data)
        ,
          (response) ->
            if response.status > 0
              scope.uploadingError = response.status + ': ' + response.data
        ,
          (evt) ->
            scope.uploadingProgress = Math.min(100, parseInt(100.0 * evt.loaded / evt.total))
        )
  }
)
