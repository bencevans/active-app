# active-app

> Detect the active window/application on Linux (X11) and hopefully more platforms in the future...

Anyone with experience in Windows/OSX development, I'd appreciate some help
adding support to this module

## Install

```
$ npm install active-app
```

## Usage

```js
const activeApp = require('active-app')

activeApp((err, app) => {
  if (err) {
    return console.error(err)
  }

  console.log(app)
})

// { desktopNumber: 0,
//   processId: 12685,
//   xOffset: 106,
//   yOffset: 85,
//   width: 1547,
//   height: 1715,
//   machineName: 'bxps',
//   psName: 'gnome-terminal-',
//   cmdline: '/usr/lib/gnome-terminal/gnome-terminal-server',
//   windowTitle: 'watch node index.js' }
```

## Licence

MIT © [Ben Evans](http://bensbit.co.uk)
