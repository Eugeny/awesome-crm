/**
 * `ng-annotate`
 */
module.exports = function(grunt) {

  grunt.config.set('ngAnnotate', {
    dev: {
      files: [{
        expand: true,
        cwd: '.tmp/public/js/',
        src: ['*.js', '**/*.js'],
        dest: '.tmp/public/js/'
      }]
    }
  });

  grunt.loadNpmTasks('grunt-ng-annotate');
};
