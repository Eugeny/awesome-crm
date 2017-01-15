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
      if(i.comment) lines.push("Comment: "+ i.comment);
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
        comment: lines.join("\n")
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

      toPersist.push({
        name: i.name,
        serialNumber: i.sn,
        type: i.type,
        config: delHash(i.config),
        company: persisted.companies[i.company_id],
        sale: persisted.sales[i.project_id],
        manufactured_on: moment(i.manufactured_on, 'DD.MM.YYYY')._d,
        maintenance_start: moment(i.maintenance_start, 'DD.MM.YYYY')._d,
        maintenance_end: moment(i.maintenance_end, 'DD.MM.YYYY')._d,
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

module.exports.bootstrap = function(cb) {
  fs.readFile('1.json', function(err, data){
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
      ];

      var f = function(){
        if(funcs.length){
          var cur = funcs.shift();
          cur().then(f);
        }else{
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
