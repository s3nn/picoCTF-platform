React = require 'react'

History = (require "react-router").History

RB = require 'react-bootstrap'

Api = require '../utils/api'

UserLogoutPage = React.createClass
  mixins: [History]

  getInitialState: ->
    Api.call "GET", "/api/user/logout"
    .done (resp) =>
      Api.notify resp
      if resp.status == "success"
        @props.onStatusChange()
        @history.push "/"
        success : true
      else
        success : false

  render: ->
    if @state.success
      <p>Logout successful. Redirecting..</p>
    else
      <p>Logout unsuccessful. Please try again.</p>

module.exports = UserLogoutPage
