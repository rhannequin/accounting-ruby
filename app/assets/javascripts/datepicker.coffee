#= require bootstrap-datepicker/core
#= require bootstrap-datepicker/locales/bootstrap-datepicker.fr.js

$(document).on 'turbolinks:load', ->

  $('input.datepicker').datepicker
    language: APP.locale
    todayHighlight: yes
