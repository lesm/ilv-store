// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import '@hotwired/turbo-rails'

import * as ActiveStorage from "@rails/activestorage"
ActiveStorage.start()

import 'controllers'
import 'controllers/actions/animate_cart_action'
import 'controllers/actions/redirect_action'
