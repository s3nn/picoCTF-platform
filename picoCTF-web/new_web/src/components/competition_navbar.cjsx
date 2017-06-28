React = require 'react'

ReactRouter = require "react-router"
Link = ReactRouter.Link

RB = require 'react-bootstrap'
Navbar = RB.Navbar
Nav = RB.Nav
NavItem = RB.NavItem
NavDropdown = RB.NavDropdown
MenuItem = RB.MenuItem
Glyphicon = RB.Glyphicon
Col = RB.Col
Row = RB.Row

_ = require "underscore"

ReactHelper = require "../utils/react_helper"

inactiveCompetitionBlacklist = ["Problems"]
anonymousBlacklist = ["Shell", "Problems", "Logout"]
loggedInBlacklist = ["Login", "Register"]

accessMapping =
  user:
    Problems: "/problems"
    Shell: "/shell"
    Scoreboard: "/scoreboard"
    Login: "/login"
    Register: "/register"
  teacher:
    Problems: "/problems"
    Shell: "/shell"
    Scoreboard: "/scoreboard"
    Classroom: "/classroom"
  admin:
    Problems: "/problems"
    Shell: "/shell"
    Scoreboard: "/scoreboard"
    Classroom: "/classroom"
    Management: "/management"


objectFilter = (object, f) ->
  newObject = {}
  _.forEach object, (val, key) ->
    if f(val, key)
      newObject[key] = val
  newObject

CompetitionNavbar = React.createClass
  render: ->

    if @props.status
      if @props.status.admin
        role = "admin"
      else if @props.status.teacher
        role = "teacher"
      else
        role = "user"

      activeProfile = accessMapping[role]

      #Filter navigation tabs
      if not @props.status.competition_active
        activeProfile = objectFilter activeProfile, (val, key) ->
          not(_.contains inactiveCompetitionBlacklist, key)

      if not @props.status.logged_in
        activeProfile = objectFilter activeProfile, (val, key) ->
          not(_.contains anonymousBlacklist, key)
      else
        activeProfile = objectFilter activeProfile, (val, key) ->
          not(_.contains loggedInBlacklist, key)
    else
      activeProfile = {}

    <Navbar inverse>
      <Navbar.Header>
        <Navbar.Brand>
          <Link to="/">CTF Placeholder</Link>
        </Navbar.Brand>
        <Navbar.Toggle />
      </Navbar.Header>
      <ReactHelper.ShowIf truthy={@props.status.logged_in}>
        <Navbar.Collapse>
          <Nav pullRight>
            <li>
              <Link to="/account">
                <Glyphicon glyph="user"/> {@props.status.username}
              </Link>
            </li>
            <li>
              <Link to="/profile">
                <Glyphicon glyph="flash"/> {@props.status.score}
              </Link>
            </li>
            <li>
              <Link to="/logout">Logout</Link>
            </li>
          </Nav>
        </Navbar.Collapse>
      </ReactHelper.ShowIf>
      <Navbar.Collapse>
        <Nav pullRight>
          {_.map activeProfile, (val, key) ->
            <li key={key}>
              <Link to={val}>{key}</Link>
            </li>}
        </Nav>
      </Navbar.Collapse>
    </Navbar>

module.exports = CompetitionNavbar
