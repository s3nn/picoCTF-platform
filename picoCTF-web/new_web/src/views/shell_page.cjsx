React = require 'react'

History = (require "react-router").History

RB = require 'react-bootstrap'
Grid = RB.Grid
Col = RB.Col

ShellServerList = require '../components/shell_server_list'

update = require 'react-addons-update'

Api = require '../utils/api'

ReactHelper = require "../utils/react_helper"
ShowIf = ReactHelper.ShowIf

ShellPage = React.createClass

  getInitialState: ->
    servers: []

  componentWillMount: ->
    Api.call "GET", "/api/user/shell_servers"
    .done (resp) =>
      if resp.status == "success"
        @setState update @state,
          $set: servers: resp.data

  render: ->
    serverView = React.cloneElement @props.children,
      key: document.location.pathname
      servers: @state.servers

    <Grid fluid={true}>
      <ShowIf truthy={@state.servers.length > 1}>
        <Col xs={3}>
          <ShellServerList servers={@state.servers}/>
        </Col>
        <Col xs={9}>
          {serverView}
        </Col>
      </ShowIf>
      <ShowIf truthy={@state.servers.length <= 1}>
        <Col xs={10} xsOffset={1}>
          {serverView}
        </Col>
      </ShowIf>
    </Grid>

module.exports = ShellPage
