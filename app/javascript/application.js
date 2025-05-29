// Entry point for the build script in your package.json
import '@hotwired/turbo-rails'
import './controllers'
import * as bootstrap from 'bootstrap'
import './chartkick'
// import 'chartkick/chart.js'
// import 'chartjs-adapter-moment'
// import 'Chart.bundle'

window.bootstrap = bootstrap
