React = require 'react'

Link = (require "react-router").Link
History = (require "react-router").History

RB = require 'react-bootstrap'

Panel = RB.Panel

_ = require 'underscore'

ShellServer = React.createClass

  getInitialState: ->
    url: "#{@props.protocol.toLowerCase()}://#{@props.host}/shell"

  makeHeader: ->
    <div>
      <div className="text-center">
        <strong>{@props.host}</strong>
        {" - "}
        <a href={@state.url}>Full Screen</a>
      </div>
    </div>

  render:->
    <Panel className="panel-info" header={@makeHeader()}>
      <iframe src={@state.url} width="100%" height="600px"></iframe>
    </Panel>

module.exports = ShellServer
