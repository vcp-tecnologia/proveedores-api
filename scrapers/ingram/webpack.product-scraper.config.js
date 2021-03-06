var webpack = require('webpack');
var path = require('path');
var fs = require('fs');

var nodeModules = {};

// Manually add the native Phantom JS modules used in the project
nodeModules['webpage'] = 'commonjs webpage';
nodeModules['system'] = 'commonjs system';
nodeModules['fs'] = 'commonjs fs';

module.exports = {
  target: 'node',

  entry: [
    './src/scrapers/product_scraper'
  ],

  output: {
    path: path.join(__dirname, 'dist'),
    filename: 'product_scraper.js'
  },

  externals: nodeModules,

  node: {
    __dirname: true
  },

  module: {
    loaders: [
      {
        loader: 'babel',

        test: /\.js$/,

        exclude: [
          /node_modules/,
        ],

        query: {
          plugins: ['transform-runtime'],
          presets: ['es2015', 'stage-0'],
        },
      },

      {
        loader: 'json',
        
        test: /\.json$/, 
      },
    ]
  },

  resolve: {
    extensions: ['', '.js', '.json']
  }
}