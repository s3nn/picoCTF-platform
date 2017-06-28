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

class UserRegistrationPage extends React.Component
  mixins: [LinkedStateMixin, History]

  getInitialState: ->
    username: ""
    password: ""

  componentWillMount: ->
    Api.call "GET", "/api/team/settings"
    .success (resp) =>
      @setState update @state,
        teamSettings: $set: resp.data

  onUserLogin: (e) ->
    e.preventDefault()
    Api.call "POST", "/api/user/login", {username: @state.username, password: @state.password}
    .done (resp) =>
      if resp.status == "success"
        @history.push "/profile"
      else
        Api.notify resp

  render: ->

    <Row>
      <div>
        {if @props.groupName.length > 0 then showGroupMessage() else <span/>}
        {if @props.emailFilter.length > 0 and not @props.rid then showEmailFilter() else <span/>}
      </div>
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

module.exports = UserRegistrationPage
