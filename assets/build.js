const esbuild = require('esbuild')

const args = process.argv.slice(2)
const compile = args.includes('--compile')

const loader = {
  // Add loaders for images/fonts/etc, e.g. { '.svg': 'file' }
}

console.log(process.env)

const plugins = [

]

let opts = {
  entryPoints: ['js/app.js'],
  bundle: true,
  target: 'es2017',
  outdir: '../priv/static/demoo',
  logLevel: 'info',
  loader,
  plugins
}

if (compile) {
  opts = {
    ...opts,
    minify: false
  }
}

const promise = esbuild.build(opts)
