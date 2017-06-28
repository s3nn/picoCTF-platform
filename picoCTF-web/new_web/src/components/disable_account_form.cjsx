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

DisableAccountForm = React.createClass
  mixins: [LinkedStateMixin, History]

  getInitialState : ->
    {}

  onDisable: (e) ->
    e.preventDefault()
    Api.confirmDialog "This will disable your account, drop you from your team, and prevent you from playing!", (=>
      Api.call "POST", "/api/user/disable_account", @state
      .done (resp) =>
        Api.notify resp
        if resp.status == "success"
          @props.onStatusChange()
          @history.push "/"
    ), "Disable Account", "Cancel", "top", "danger"

  makeHeader: ->
    <div>
      <h3 className="panel-title">Disable Account</h3>
      <em>This is permanent action; you can not undo this.</em>
    </div>

  render: ->
    lockGlyph = <Glyphicon glyph="lock"/>

    <Panel header={@makeHeader()} bsStyle="danger">
      <form onSubmit={@onDisable}>
        <p>Disabling your account will remove you from the competition. You will not be able to log in once you disable your account. Disabled accounts cannot be re-enabled.</p>
        <Input type="password" valueLink={@linkState "current-password"} addonBefore={lockGlyph} label="Current Password" required/>
        <Button bsStyle="danger" type="submit">Disable Account</Button>
      </form>
    </Panel>

module.exports = DisableAccountForm
