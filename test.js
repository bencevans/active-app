import test from 'ava'
import activeApp from './'

test('retrieves current application details', (t) => {
  t.plan(2)
  activeApp((err, app) => {
    console.log('wooo')
    t.ifError(err)
    t.is('no' , 'string')
    t.end()
    // t.pass()
  })
})
