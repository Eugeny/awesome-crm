module.exports = function(grunt) {
  grunt.config.set('symlink', {
    dev: {
      relativeSrc: '../../uploads',
      dest: '.tmp/public/uploads',
      options: {type: 'dir'}
    },
    build: {
      relativeSrc: '../uploads',
      dest: 'www/uploads',
      options: {type: 'dir'}
    }
  });

  grunt.loadNpmTasks('grunt-symlink');
};
