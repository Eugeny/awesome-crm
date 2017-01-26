const csv = require('fast-csv')
const fs = require('fs')

const Sails = require('sails').Sails
const app = Sails()
let pending = 0

const add = (item) => {
  pending++
  let productTemplate = {
    currency: '€',
    description: item[0] + ' - ' + item[16],
    name: item[15],
    partTypeItems: [],
    price: parseInt(item[2]),
    purchasePrice: null,
    type: 'Product',
  }
  app.models.producttemplate.find({name: productTemplate.name}).exec((err, found) => {
    if (found.length == 0) {
      app.models.producttemplate.create(productTemplate).exec((err) => {
        console.log(`Added ${productTemplate.name}`)
        if (--pending == 0) {
          process.exit(0)
        }
      })
    } else {
      app.models.producttemplate.update({name: productTemplate.name}, productTemplate).exec((err) => {
        console.log(`Updated ${productTemplate.name}`)
        if (--pending == 0) {
          process.exit(0)
        }
      })
    }
  })
}


app.load({
  hooks: { grunt: false },
  log: { level: 'warn' }
}, (err) => {
  if (err) {
    console.error('Error loading app:',err);
    return process.exit(1);
  }
  fs.createReadStream('pricelist.csv')
    .pipe(csv())
    .on("data", add)
    .on("end", () => {
      console.log("done")
    })
})
