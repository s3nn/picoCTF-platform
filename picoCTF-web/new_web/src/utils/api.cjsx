$ = require "jquery"
Noty = require "noty"
Cookies = require "js-cookie"

Api = {}

Api.call = (verb, url, data) ->
  if verb == "POST"
    data.token = Cookies.get "token"
  $.ajax {url: url, type: verb, data: data, cache: false}
  .fail (jqXHR, text) ->
    Api.notify {status: "error", message: "The server is currently down. We will work to fix this error right away."}

Api.notify = (data) ->
  notification =
    type: data.status
    layout: "topRight"
    text: data.message
    timeout: 2000

  Noty(notification)

Api.confirmDialog = (text, onConfirm, confirmText, closeText, layout, confirmButtonClass) ->
  okButton =
    addClass: 'btn btn-' + if confirmButtonClass != undefined then confirmButtonClass else "primary"
    text: if confirmText != undefined then confirmText else 'Ok'
    onClick: ($noty) =>
      onConfirm()
      $noty.close()

  closeButton =
    addClass: 'btn'
    text: if closeText != undefined then closeText else 'Close'
    onClick: ($noty) ->
      $noty.close()

  notification =
    layout: if layout != undefined then layout else 'top'
    text: text
    buttons: [okButton, closeButton]

  Noty(notification)


module.exports = Api
