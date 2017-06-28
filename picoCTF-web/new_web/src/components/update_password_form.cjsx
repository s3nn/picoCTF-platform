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

# Should figure out how we want to share components.
UpdatePasswordForm = React.createClass
  mixins: [LinkedStateMixin, History]

  getInitialState: ->
    user: {}
    team: {}

  componentWillMount: ->
    Api.call "GET", "/api/team/settings"
    .done (api) =>
      @setState update @state,
        team: $set: api.data

  onUpdate: (e) ->
    e.preventDefault()
    Api.call "POST", "/api/user/update_password", @state
    .done (resp) =>
      Api.notify resp
      if resp.status == "success"
        @props.onStatusChange()
        @history.push "/profile"

  makeHeader: ->
    <div>
      <h3 className="panel-title">Update Password</h3>
    </div>

  render: ->
    lockGlyph = <Glyphicon glyph="lock"/>

    <Panel header={@makeHeader()}>
      <form onSubmit={@onUpdate}>
        <Input type="password" valueLink={@linkState "current-password"} addonBefore={lockGlyph} label="Current Password" required/>
        <Input type="password" valueLink={@linkState "new-password"} addonBefore={lockGlyph} label="New Password" required/>
        <Input type="password" valueLink={@linkState "new-password-confirmation"} addonBefore={lockGlyph} label="Repeat New Password" required/>
        <Button type="submit">Update Password</Button>
      </form>
    </Panel>

module.exports = UpdatePasswordForm
