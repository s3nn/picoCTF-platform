React = require 'react'
update = require 'react-addons-update'

Noty = require 'noty'

Api = require './utils/api'

CompetitionNavbar = require "./components/competition_navbar"

App = React.createClass

  getInitialState: ->
    status: {}

  onStatusChange: ->
    Api.call "GET", "/api/user/status"
    .success (resp) =>
      @setState update @state,
        status: $set: resp.data

  componentWillMount: ->
    @onStatusChange()

  render: ->
    childrenWithProps = React.Children.map @props.children, (child) =>
                          React.cloneElement child,
                            status: @state.status
                            onStatusChange: @onStatusChange
    <div>
      <CompetitionNavbar status={@state.status}/>
      <div id="page">
        {childrenWithProps}
      </div>
    </div>

module.exports = App
