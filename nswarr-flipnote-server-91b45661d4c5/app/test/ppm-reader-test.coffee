reader = require '../lib/ppm-reader'
fs = require 'fs'

console.log process.cwd()

data = fs.readFileSync './app/test/KD4F97_1524FC3CC2443_000.ppm'

results = reader.process data
