#!/usr/bin/env coffee

fs = require('fs')
path = require('path')
readline = require('readline')
rl = readline.createInterface(
  input: process.stdin,
  output: process.stdout
)

args = process.argv
dir = __dirname

if !args[2] or !args[3]
  console.log("Usage: #{args[1]} singular plural")
  console.log("Example: #{args[1]} person people")
  process.exit()


singular = args[2]
plural = args[3]

processTemplate = (s) -> s.replace(/PLURAL/g, plural).replace(/SINGULAR/g, singular)

copy = () ->
  copyRec = (from, to) ->
    fs.stat(from, (err, stats) ->
      throw err if err
      if stats.isDirectory()
        fs.mkdir(to, () ->
          fs.readdir(from, (err, files) ->
            throw err if err
            copyRec(path.join(from, i), processTemplate(path.join(to, i))) for i in files
          )
        )
      else
        do (from, to) ->
          fs.readFile(from, (err, data) ->
            fs.writeFile(processTemplate(to), processTemplate(data))
          )
    )

  copyRec("#{dir}/template", "#{dir}/../assets")
  rl.close()

exists = false
try
  fs.statSync("#{dir}/../assets/js/#{plural}")
  exists = true
try
  fs.statSync("#{dir}/../assets/partials/app/#{plural}")
  exists = true

if exists
  rl.question('Destination path exists, type yes to overwrite it: ', (s) ->
    copy() if s == "yes"
  )
else
  copy()
