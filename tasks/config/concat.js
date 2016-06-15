/**
 * `concat`
 *
 * ---------------------------------------------------------------
 *
 * Concatenates the contents of multiple JavaScript and/or CSS files
 * into two new files, each located at `concat/production.js` and
 * `concat/production.css` respectively in `.tmp/public/concat`.
 *
 * This is used as an intermediate step to generate monolithic files
 * that can then be passed in to `uglify` and/or `cssmin` for minification.
 *
 * For usage docs see:
 *   https://github.com/gruntjs/grunt-contrib-concat
 *
 */
module.exports = function(grunt) {

  isDep = function(x){return x.indexOf('bower_components') != -1 || x.indexOf('node_modules') != -1;};

  grunt.config.set('concat', {
    jsDeps: {
      src: require('../pipeline').jsFilesToInject.filter(isDep),
      dest: '.tmp/public/min/deps.min.js'
    },
    js: {
      src: require('../pipeline').jsFilesToInject.filter(isDep),
      dest: '.tmp/public/concat/production.js'
    },
    cssDeps: {
      src: require('../pipeline').cssFilesToInject.filter(isDep),
      dest: '.tmp/public/min/deps.min.css'
    },
    css: {
      src: require('../pipeline').cssFilesToInject.filter(isDep),
      dest: '.tmp/public/concat/production.css'
    }
  });

  grunt.loadNpmTasks('grunt-contrib-concat');
};
