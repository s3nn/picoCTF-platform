React = require 'react'

History = (require "react-router").History
Link = (require "react-router").Link

RB = require 'react-bootstrap'
Panel = RB.Panel
ListGroup = RB.ListGroup
ListGroupItem = RB.ListGroupItem
Glyphicon = RB.Glyphicon

_ = require 'underscore'

ShellServerList = React.createClass
  mixins: [History]

  propTypes:
    servers: React.PropTypes.array.isRequired

  makeServerEntry: (server) ->
    <ListGroupItem key={server.sid}>
      <Link to={"/shell/#{server.sid}"}>
        <Glyphicon glyph="hdd"/> {server.host}
      </Link>
    </ListGroupItem>

  render: ->
    header = <strong>Shell servers</strong>

    <Panel header={header}>
      <ListGroup>
        {_.map @props.servers, @makeServerEntry}
      </ListGroup>
    </Panel>

module.exports = ShellServerList
