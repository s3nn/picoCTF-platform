React = require 'react'

Link = (require "react-router").Link
History = (require "react-router").History

LinkedStateMixin = require 'react-addons-linked-state-mixin'

RB = require 'react-bootstrap'

Panel = RB.Panel
Input = RB.Input
Col = RB.Col
Button = RB.Button
Glyphicon = RB.Glyphicon

_ = require 'underscore'

Api = require "../utils/api"

update = require 'react-addons-update'

TeamManagementForm = React.createClass
  mixins: [LinkedStateMixin, History]

  getInitialState: ->
    user: {}
    team: {}

  componentWillMount: ->
    Api.call "GET", "/api/team/settings"
    .done (api) =>
      @setState update @state,
        team: $set: api.data

  onTeamRegistration: (e) ->
    e.preventDefault()
    Api.call "POST", "/api/team/create", {team_name: @state.team_name, team_password: @state.team_password}
    .done (resp) ->
      Api.notify resp
      if resp.status == "success"
        @history.push "/profile"

  onTeamJoin: (e) ->
    e.preventDefault()
    Api.call "POST", "/api/team/join", {team_name: @state.team_name, team_password: @state.team_password}
    .done (resp) ->
      Api.notify resp
      if resp.status == "success"
        @history.push "/profile"

  makeHeader: ->
    <div>
      <h3 className="panel-title">Team Management</h3>
    </div>

  render: ->
    if @state.team.max_team_size > 1
      towerGlyph = <Glyphicon glyph="tower"/>
      lockGlyph = <Glyphicon glyph="lock"/>

      shouldDisable = @props.status.user and @props.status.username != @state.user.team_name

      <Panel header={@makeHeader()}>
        <form onSubmit={@onTeamJoin}>
          {if shouldDisable then <p>You can not switch or register your account to another team.</p> else <span/>}
          <Input type="text" valueLink={@linkState "team_name"} addonBefore={towerGlyph} label="Team Name" required disabled={shouldDisable}/>
          <Input type="password" valueLink={@linkState "team_password"} addonBefore={lockGlyph} label="Team Password" required disabled={shouldDisable}/>
          <Col md={6}>
            <span>
              <Button type="submit" disabled={shouldDisable}>Join Team</Button>
              <Button onClick={@onTeamRegistration} disabled={shouldDisable}>Register Team</Button>
            </span>
          </Col>
        </form>
      </Panel>
    else
      <div/>

module.exports = TeamManagementForm
