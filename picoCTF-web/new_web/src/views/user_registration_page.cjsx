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
ButtonInput = RB.ButtonInput

update = require 'react-addons-update'
LinkedStateMixin = require 'react-addons-linked-state-mixin'

Api = require '../utils/api'

UserRegistrationPage = React.createClass
  mixins: [LinkedStateMixin, History]

  getInitialState: ->
    eligibility: "eligible"

  componentWillMount: ->
    Api.call "GET", "/api/team/settings"
    .success (resp) =>
      @setState update @state,
        teamSettings: $set: resp.data

  onUserRegistration: (e) ->
    e.preventDefault()
    Api.call "POST", "/api/user/create_simple", @state
    .done (resp) =>
      Api.notify resp
      if resp.status == "success"
        @props.onStatusChange()
        @history.push "/profile"

  render: ->

    userGlyph = <Glyphicon glyph="user"/>
    lockGlyph = <Glyphicon glyph="lock"/>

    <Grid>
      <Panel>
        <form onSubmit={@onUserRegistration}>
          <Row>
            <Col md={6}>
              <Input type="text" id="username" valueLink={@linkState "username"} addonBefore={userGlyph} label="Username"/>
            </Col>
            <Col md={6}>
              <Input type="password" id="password" valueLink={@linkState "password"} addonBefore={lockGlyph} label="Password"/>
            </Col>
          </Row>
          <Row>
            <Col md={6}>
              <Input type="text" id="first-name" valueLink={@linkState "firstname"} label="First Name"/>
            </Col>
            <Col md={6}>
              <Input type="text" id="last-name" valueLink={@linkState "lastname"} label="Last Name"/>
            </Col>
          </Row>
          <Row>
            <Col md={12}>
              <Input type="email" id="email" valueLink={@linkState "email"} label="E-mail"/>
            </Col>
          </Row>
          <Row>
            <Col md={6}>
              <Input type="text" id="affiliation" valueLink={@linkState "affiliation"} label="Affiliation"/>
            </Col>
            <Col md={6}>
              <Input type="select" label="Status" placeholder="Competitor" valueLink={@linkState "eligibility"}>
                <option value="eligible">Competitor</option>
                <option value="ineligible">Instructor</option>
                <option value="ineligible">Other</option>
              </Input>
            </Col>
          </Row>
          <ButtonInput type="submit">Register</ButtonInput>
        </form>
      </Panel>
    </Grid>

module.exports = UserRegistrationPage
