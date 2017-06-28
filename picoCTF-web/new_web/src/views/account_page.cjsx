React = require 'react'

History = (require "react-router").History

RB = require 'react-bootstrap'
Grid = RB.Grid
Col = RB.Col
Row = RB.Row

TeamManagementForm = require '../components/team_management_form'
DisableAccountForm = require '../components/disable_account_form'
UpdatePasswordForm = require '../components/update_password_form'

update = require 'react-addons-update'

Api = require '../utils/api'

ReactHelper = require "../utils/react_helper"

AccountPage = React.createClass
    render: ->
      <Grid>
        <Col xs={6}>
          <Row>
            <DisableAccountForm {...@props}/>
          </Row>
          <Row>
            <TeamManagementForm {...@props}/>
          </Row>
        </Col>
        <Col xs={6}>
          <UpdatePasswordForm {...@props}/>
        </Col>
      </Grid>

module.exports = AccountPage
