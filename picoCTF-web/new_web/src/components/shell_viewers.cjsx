React = require 'react'

History = (require "react-router").History

RB = require 'react-bootstrap'

Row = RB.Row
Col = RB.Col

_ = require 'underscore'

ShellServer = require './shell_server'

ReactHelper = require "../utils/react_helper"
ShowIf = ReactHelper.ShowIf

Viewer = React.createClass

  propTypes:
    servers: React.PropTypes.array.isRequired

  render: ->
    shownServers = @props.showFilter @props.servers

    <div>
      <Row id="server">
        {_.map shownServers, (server) =>
          <ShellServer key={server.sid} {...server}/>}
      </Row>
    </div>


ShellViewer = React.createClass

  sidFilter: (servers) ->
    _.filter servers, (server) =>
      server.sid == @props.params.sid

  render: ->
    <Viewer showFilter={@sidFilter} {...@props}/>

DefaultShellViewer = React.createClass

  defaultFilter: (servers) ->
    # display first one only by default
    if servers.length > 0 then [_.first servers] else []

  render: ->
    <Viewer showFilter={@defaultFilter} {...@props}/>

module.exports =
  DefaultShellViewer: DefaultShellViewer
  ShellViewer: ShellViewer
