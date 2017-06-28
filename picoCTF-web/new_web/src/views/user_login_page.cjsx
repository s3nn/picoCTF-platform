React = require 'react'

History = (require "react-router").History

RB = require 'react-bootstrap'

Glyphicon = RB.Glyphicon
Panel = RB.Panel
Input = RB.Input
Row = RB.Row
Col = RB.Col
Button = RB.Button
Grid = RB.Grid

update = require 'react-addons-update'
LinkedStateMixin = require 'react-addons-linked-state-mixin'

Api = require '../utils/api'

UserLoginPage = React.createClass
  mixins: [LinkedStateMixin, History]

  getInitialState: ->
    username: ""
    password: ""

  onUserLogin: (e) ->
    e.preventDefault()
    Api.call "POST", "/api/user/login", {username: @state.username, password: @state.password}
    .done (resp) =>
      Api.notify resp
      if resp.status == "success"
        @props.onStatusChange()
        @history.push "/profile"
      else
        Api.notify resp

  render: ->
    userGlyph = <Glyphicon glyph="user"/>
    lockGlyph = <Glyphicon glyph="lock"/>

    <Grid>
      <Panel>
        <form onSubmit={@onUserLogin}>
          <Input type="text" id="username" valueLink={@linkState "username"} addonBefore={userGlyph} label="Username"/>
          <Input type="password" id="password" valueLink={@linkState "password"} addonBefore={lockGlyph} label="Password"/>
          <Row>
            <Col md={6}>
              <Button type="submit">Login</Button>
            </Col>
            <Col md={6}>
              <a className="pad" onClick={() => @history.push "/reset"}>Need to reset your password?</a>
            </Col>
          </Row>
        </form>
      </Panel>
    </Grid>

module.exports = UserLoginPage
