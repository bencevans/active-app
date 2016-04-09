'use strict'
const exec = require('child_process').exec
const os = require('os')

function activeApp(cb) {
  if (os.platform() === 'linux') {
    return linux(cb)
  } else {
    return cb(new Error('Unsupported Platform'))
  }
}

function linux(cb) {
  exec('/bin/bash ' + __dirname + '/log-active-x11-window.sh', function (err, stdout) {
    if (err) {
      return cb(err)
    }
    let split = stdout.split('\\t')

    try {
      let out = {
        'desktopNumber': parseInt(split[0], 10),
        'processId': parseInt(split[1], 10),
        'xOffset': parseInt(split[2], 10),
        'yOffset': parseInt(split[3], 10),
        'width': parseInt(split[4], 10),
        'height': parseInt(split[5], 10),
        'machineName': split[6],
        'psName': split[7],
        'cmdline': split[8], // (NUL separated)
        'windowTitle': split[9].match(/(.+)\n?/)[1] // (could contain spaces)
      }
      return cb(null, out)
    } catch (err) {
      return cb(err)
    }
  }) 
}

module.exports = activeApp

