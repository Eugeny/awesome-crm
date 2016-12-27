# Installation

```
npm install -g grunt bower
npm install
```

Install wkhtml2pdf system-wide for using reports

# Running
`sails lift`

# wkhtmltopdf font rendering fix

`/etc/fonts/conf.d/99-fix.conf` ->

```
<?xml version='1.0'?>
<!DOCTYPE fontconfig SYSTEM 'fonts.dtd'>
<fontconfig>
 <match target="font">
  <edit mode="assign" name="rgba">
   <const>rgb</const>
  </edit>
 </match>
 <match target="font">
  <edit mode="assign" name="hinting">
   <bool>true</bool>
  </edit>
 </match>
 <match target="font">
  <edit mode="assign" name="hintstyle">
   <const>hintslight</const>
  </edit>
 </match>
 <match target="font">
  <edit mode="assign" name="antialias">
   <bool>true</bool>
  </edit>
 </match>
  <match target="font">
    <edit mode="assign" name="lcdfilter">
      <const>lcddefault</const>
    </edit>
  </match>
</fontconfig>
```

# sample config

`config/local.js` ->

```
module.exports = {
  // ssl: {
  //   ca: require('fs').readFileSync(__dirname + './ssl/my_apps_ssl_gd_bundle.crt'),
  //   key: require('fs').readFileSync(__dirname + './ssl/my_apps_ssl.key'),
  //   cert: require('fs').readFileSync(__dirname + './ssl/my_apps_ssl.crt')
  // },

  // port: process.env.PORT || 1337,

  // environment: process.env.NODE_ENV || 'development'

  permissions: {
    adminUsername: 'admin',
    adminEmail: 'admin@example.com',
    adminPassword: 'admin1234'
  },

  session: {
    adapter: 'mongo',
    url: 'mongodb://docker:27017/crm_session' // user, password and port optional
  },

  connections: {
    mongo: {
      adapter: 'sails-mongo',
      host: 'docker',
      port: 27017,
      database: 'crm' //optional
    }
  },

  models:{
    connection: 'mongo'
  },

  wkhtmltopdfCommand: 'xvfb wkhtmltopdf'
};
```
