#!/usr/bin/env node

const _ = require('lodash/fp')
const file = process.argv[process.argv.length-1]
const char = require(file)
const icons = _.flow(
  _.values,
  _.map('icon'),
  _.uniq,
  _.filter(_.identity),
  _.sortBy(_.identity),
)(char.levelGraphNodeTypes)
icons.map(icon => console.log(icon))
