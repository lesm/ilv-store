# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin 'application'
pin '@hotwired/turbo-rails', to: 'turbo.min.js'
pin '@hotwired/stimulus', to: 'stimulus.min.js'
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js'
pin 'el-transition'
pin '@rails/request.js', to: '@rails--request.js.js'
pin '@rails/activestorage', to: 'activestorage.esm.js'
pin_all_from 'app/javascript/controllers', under: 'controllers'
