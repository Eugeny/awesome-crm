/**
 * grunt/pipeline.js
 *
 * The order in which your css, javascript, and template files should be
 * compiled and linked from your views and static HTML files.
 *
 * (Note that you can take advantage of Grunt-style wildcard/glob/splat expressions
 * for matching multiple files.)
 *
 * For more information see:
 *   https://github.com/balderdashy/sails-docs/blob/master/anatomy/myApp/tasks/pipeline.js.md
 */


// CSS files to inject in order
//
// (if you're using LESS with the built-in default config, you'll want
//  to change `assets/styles/importer.less` instead.)
var cssFilesToInject = [
  'bower_components/gentelella/vendors/bootstrap/dist/css/bootstrap.min.css',
  'bower_components/gentelella/vendors/font-awesome/css/font-awesome.min.css',
  'bower_components/gentelella/vendors/iCheck/skins/flat/green.css',
  'bower_components/gentelella/vendors/bootstrap-progressbar/css/bootstrap-progressbar-3.3.4.min.css',
  // 'bower_components/gentelella/production/css/maps/jquery-jvectormap-2.0.3.css',
  'bower_components/gentelella/build/css/custom.min.css',
  'bower_components/gentelella/vendors/font-awesome/fonts/fontawesome-webfont.woff2',
  'bower_components/gentelella/vendors/bootstrap/dist/fonts/glyphicons-halflings-regular.woff2',
  'bower_components/angular-formstamp/dist/formstamp.css',

  'styles/**/*.css'
];


// Client-side javascript files to inject in order
// (uses Grunt-style wildcard/glob/splat expressions)
var jsFilesToInject = [

  // Load sails.io before everything else
  'js/dependencies/sails.io.js',

  // Dependencies like jQuery, or Angular are brought in here
  'js/dependencies/**/*.js',
  'bower_components/angular/angular.min.js',
  'bower_components/angular-ui-router/release/angular-ui-router.min.js',
  'bower_components/angular-resource/angular-resource.min.js',

  'bower_components/gentelella/vendors/jquery/dist/jquery.min.js',
  'bower_components/gentelella/vendors/bootstrap/dist/js/bootstrap.min.js',
  'bower_components/gentelella/build/js/custom.min.js',

  'bower_components/angular-formstamp/dist/formstamp.js',
  'bower_components/moment/min/moment.min.js',
  'bower_components/angular-moment/angular-moment.min.js',
  'node_modules/ng-country-select/dist/ng-country-select.min.js',

  // All of the rest of your client-side js files
  // will be injected here in no particular order.
  'js/**/*.js'
];


// Client-side HTML templates are injected using the sources below
// The ordering of these templates shouldn't matter.
// (uses Grunt-style wildcard/glob/splat expressions)
//
// By default, Sails uses JST templates and precompiles them into
// functions for you.  If you want to use jade, handlebars, dust, etc.,
// with the linker, no problem-- you'll just want to make sure the precompiled
// templates get spit out to the same file.  Be sure and check out `tasks/README.md`
// for information on customizing and installing new tasks.
var templateFilesToInject = [
  'templates/**/*.html'
];

// Default path for public folder (see documentation for more information)
var tmpPath = '.tmp/public/';

// Prefix relative paths to source files so they point to the proper locations
// (i.e. where the other Grunt tasks spit them out, or in some cases, where
// they reside in the first place)
module.exports.cssFilesToInject = cssFilesToInject.map(function(cssPath) {
  return require('path').join('.tmp/public/', cssPath);
});
module.exports.jsFilesToInject = jsFilesToInject.map(function(jsPath) {
  return require('path').join('.tmp/public/', jsPath);
});
module.exports.templateFilesToInject = templateFilesToInject.map(function(tplPath) {
  return require('path').join('assets/',tplPath);
});


