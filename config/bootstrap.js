/**
 * Bootstrap
 * (sails.config.bootstrap)
 *
 * An asynchronous bootstrap function that runs before your Sails app gets lifted.
 * This gives you an opportunity to set up your data model, run jobs, or perform some special logic.
 *
 * For more information on bootstrapping your app, check out:
 * http://sailsjs.org/#!/documentation/reference/sails.config/sails.config.bootstrap.html
 */

var fs = require('fs');
var moment = require('moment');

var persisted = {
  companies: {},
  people: {},
  sales: {},
  machines: {},
  comments: {},
  users: {},
  files: {}
};

var createCompanies = function(companies){
  return new Promise(function(resolve, reject) {
    var toPersist = [];

    var k, i, p;
    for (k = 0; k < companies.length; k++) {
      i = companies[k];

      toPersist.push({
        name: i.name ? i.name : 'No Name',
        address: i.address,
        zip: i.zip,
        city: i.city,
        country: i.country,
        website: i.website,
        fax: i.fax,
        phone: i.phone,
        email: i.email,
        subtype: i.subtype,
        type: i.type
      });
    }

    sails.log.info('Inserting ' + toPersist.length + ' companies');
    Company.create(toPersist).exec(function(err, created){
      if(err){
        sails.log.error('Error: ' + err);
        reject(err);
      }else{
        for(var i = 0; i < created.length; i++){
          persisted.companies[companies[i].id] = created[i];
        }
        resolve();
      }
    });
  });
};

var createPeople = function(people){
  return new Promise(function(resolve, reject) {
    var toPersist = [];

    var k, i, p;
    for (k = 0; k < people.length; k++) {
      i = people[k];

      toPersist.push({
        firstName: i.first_name,
        lastName: i.last_name,
        website: i.website,
        hasOwnAddress: !!(i.address || i.zip || i.city || i.country),
        address: i.address,
        zip: i.zip,
        city: i.city,
        country: i.country,
        phone: i.phone,
        fax: i.fax,
        email: i.email,
        company: persisted.companies[i.company_id]
      });
    }

    sails.log.info('Inserting ' + toPersist.length + ' people');
    Person.create(toPersist).exec(function(err, created){
      if(err){
        sails.log.error('Error: ' + err);
        reject(err);
      }else{
        for(var i = 0; i < created.length; i++){
          persisted.people[people[i].id] = created[i];

          if(people[i].is_company_contact){
            Company.update(created[i].company, {contactPerson: created[i].id});
          }
        }
        resolve();
      }
    });
  });
};

var createSales = function(sales){
  return new Promise(function(resolve, reject) {
    var toPersist = [];

    var k, i, p;
    for (k = 0; k < sales.length; k++) {
      i = sales[k];

      var lines = [];
      var comments = [];
      if(i.comment) comments.push({text:i.comment});
      if(i.topic) lines.push("Topic: "+ i.topic);
      if(i.throughput) lines.push("Throughput: "+ i.throughput);
      if(i.num_clients_san) lines.push("Num Clients San: "+ i.num_clients_san);
      if(i.num_clients_nas) lines.push("Num Clients Nas: "+ i.num_clients_nas);
      if(i.date) lines.push("Date: "+ i.date);

      toPersist.push({
        name: i.name,
        company: persisted.companies[i.company_id],
        companyContact: persisted.people[i.contact_id],
        localContact: persisted.people[i.internal_contact_id],
        state: i.status,
        description: lines.join("\n"),
        comments: comments
      });
    }

    sails.log.info('Inserting ' + toPersist.length + ' sales');
    Sale.create(toPersist).exec(function(err, created){
      if(err){
        sails.log.error('Error: ' + err);
        reject(err);
      }else{
        for(var i = 0; i < created.length; i++){
          persisted.sales[sales[i].id] = created[i];
        }
        resolve();
      }
    });
  });
};

var createMachines = function(machines){
  var delHash = function(o){
    if(!o || typeof o != 'object') return o;
    delete o.$$hashKey;
    for(var k in o){
      delHash(o[k]);
    }
    return o;
  };

  return new Promise(function(resolve, reject) {
    var toPersist = [];

    var k, i, p;
    for (k = 0; k < machines.length; k++) {
      i = machines[k];

      var manufacturedOn = moment(i.manufactured_on, 'DD.MM.YYYY')._d;
      var maintenanceStart = moment(i.maintenance_start, 'DD.MM.YYYY')._d;
      var maintenanceEnd = moment(i.maintenance_end, 'DD.MM.YYYY')._d;

      toPersist.push({
        name: i.name,
        serialNumber: i.sn,
        type: i.type,
        config: delHash(i.config),
        company: persisted.companies[i.company_id],
        sale: persisted.sales[i.project_id],
        manufacturedOn: !isNaN(manufacturedOn) ? manufacturedOn : '',
        maintenanceStart: !isNaN(maintenanceStart) ? maintenanceStart : '',
        maintenanceEnd: !isNaN(maintenanceEnd) ? maintenanceEnd : '',
        serviceLevel: i.service_level,
        softwareRelease: i.software_release,
        chassis: i.chassis,
        backplane: i.backplane,
        stornextSN: i.stornext_sn,
        stornextLicense: i.stornext_license,
        cvfsID: i.cvfs_id,
        comment: i.comment
      });
    }

    sails.log.info('Inserting ' + toPersist.length + ' machines');
    Machine.create(toPersist).exec(function(err, created){
      if(err){
        sails.log.error('Error: ' + err);
        reject(err);
      }else{
        for(var i = 0; i < created.length; i++){
          persisted.machines[machines[i].id] = created[i];
        }
        resolve();
      }
    });
  });
};

var createUsers = function(users){
  return new Promise(function(resolve, reject) {
    var k, i;
    var promises = [];
    for (k = 0; k < users.length; k++) {
      i = users[k];

      (function(i) {
        promises.push(new Promise(function (resolve, reject) {
          User.register({
            username: i.username,
            firstName: i.first_name,
            lastName: i.last_name,
            email: i.email,
            password: 123456789''
          }).then(function(created){
            persisted.users[i.id] = created;
            resolve(created);
          }, function(err){
            console.log(err)
            sails.log.error('Error: ' + err);
            reject(err);
          })
        }));
      })(i);
    }

    Promise.all(promises).then(resolve, reject);

    sails.log.info('Inserting ' + promises.length + ' users');
  });
};

var createComments = function(comments){
  return new Promise(function(resolve, reject) {
    var toPersist = [];

    var k, i, p;
    for (k = 0; k < comments.length; k++) {
      i = comments[k];

      toPersist.push({
        text: i.text,
        sale: i.project_id ? persisted.sales[i.project_id] : null,
        person: i.project_id ? persisted.people[i.contact_id] : null,
        createdBy: persisted.users[i.user_id]
      });
    }

    sails.log.info('Inserting ' + toPersist.length + ' comments');
    Comment.create(toPersist).exec(function(err, created){
      if(err){
        sails.log.error('Error: ' + err);
        reject(err);
      }else{
        for(var i = 0; i < created.length; i++){
          persisted.comments[comments[i].id] = created[i];
        }
        resolve();
      }
    });
  });
};

var createFiles = function(files){
  return new Promise(function(resolve, reject) {
    var toPersist = [];

    var k, i, p, filename;
    for (k = 0; k < files.length; k++) {
      i = files[k];
      filename = i.name.replace(/[ ]/, '_');

      toPersist.push({
        text: i.text,
        sale: i.project_id ? persisted.sales[i.project_id] : null,
        machine: i.machine_id ? persisted.machines[i.machine_id] : null,
        files:[{
          fd: "/uploads/"+filename,
          filename:filename
        }],
        createdBy: persisted.users[i.user_id]
      });
    }

    sails.log.info('Inserting ' + toPersist.length + ' comments with files');
    Comment.create(toPersist).exec(function(err, created){
      if(err){
        sails.log.error('Error: ' + err);
        reject(err);
      }else{
        for(var i = 0; i < created.length; i++){
          persisted.files[files[i].id] = created[i];
        }
        resolve();
      }
    });
  });
};

module.exports.bootstrap = function(cb) {
  fs.readFile('fixtures/in.json', function(err, data){
    if(err) return cb();

    console.log(err);
    data = JSON.parse(data);

    Company.count().exec(function (err, cnt) {
      if (err || cnt) return cb();

      var funcs = [
        function(){return createCompanies(data.companies);},
        function(){return createPeople(data.contacts);},
        function(){return createSales(data.projects);},
        function(){return createMachines(data.machines);},
        function(){return createUsers(data.users);},
        function(){return createComments(data.comments);},
        function(){return createFiles(data.files);}
      ];

      var f = function(){
        if(funcs.length){
          var cur = funcs.shift();
          cur().then(f);
        }else{
          for(var i in persisted){
            for(var j in persisted[i]){
              persisted[i][j] = persisted[i][j].id
            }
          }
          fs.writeFile('fixtures/out.json', JSON.stringify(persisted));
          cb();
        }
      };

      f();

    });

  });

  // It's very important to trigger this callback method when you are finished
  // with the bootstrap!  (otherwise your server will never lift, since it's waiting on the bootstrap)
  // cb();
};
