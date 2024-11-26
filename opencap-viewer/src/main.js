import axios from 'axios'
import Vue from 'vue'
import App from './App.vue'
import vuetify from './plugins/vuetify'
import router from '@/router'
import store from '@/store/store.js'
import 'roboto-fontface/css/roboto/roboto-fontface.css'
import '@mdi/font/css/materialdesignicons.css'
import '@/assets/scss/main.scss'

import registerFilters from './util/Filters';
registerFilters(Vue)

// vee-validate 3
import { ValidationProvider, ValidationObserver, extend } from "vee-validate";
import { required, confirmed, min, email, alpha_dash } from "vee-validate/dist/rules";

// fa-icons
import '@fortawesome/fontawesome-free/css/all.css';

import VueSocialSharing from 'vue-social-sharing'

Vue.use(VueSocialSharing);

// Add rules
extend('required', required)
extend('confirmed', confirmed)
extend('min', min)
extend('email', email)
extend('alpha_dash', alpha_dash)

// Custom rules
extend('no_spaces', {
  validate (value, args) {
    return value.indexOf(' ') < 0
  },
  message: 'Spaces not allowed'
})
extend('alpha_dash_custom', {
  validate (value, args) {
    var regexp = /^[a-zA-Z0-9-_]+$/;
    if (value.search(regexp) === -1)
        return false
    else
        return true
  },
  message: 'Only alphanumeric, hyphen and underscore characters allowed.'
})
Vue.component("ValidationProvider", ValidationProvider);
Vue.component("ValidationObserver", ValidationObserver);

import Toasted from 'vue-toasted'
Vue.use(Toasted, { 
  position: 'bottom-center', 
  duration: 10000,
  className: 'vue-toasted',
  // Show all toasts with Close button
  action : {
    text : 'Close',
    onClick : (e, toastObject) => {
        toastObject.goAway(0)
    }
  }
})

Vue.toasted.register('warning', (message) => {
  Vue.toasted.show(message, {
    type: 'warning',
    theme: 'toasted-primary',
    position: 'top-right',
    className: 'warning-toast'
  });
});

Vue.config.productionTip = false

axios.defaults.baseURL = process.env.VUE_APP_API_SERVER //"https://api.opencap.ai/"
// axios.defaults.baseURL = "http://34.219.192.107/"
// axios.defaults.baseURL = "http://localhost:8000/"

store.dispatch('auth/checkToken').then(() => {
  new Vue({
    vuetify,
    router,
    store,
    render: h => h(App)
  }).$mount('#app')  
})

