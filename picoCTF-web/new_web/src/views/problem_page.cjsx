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

_ = require 'underscore'

update = require 'react-addons-update'
LinkedStateMixin = require 'react-addons-linked-state-mixin'

Api = require '../utils/api'

ProblemExplorer = require '../components/problem_explorer'

ProblemPage = React.createClass

  getInitialState: ->
    problems: []

  onProblemChange: (pid) ->
    @props.onStatusChange()
    Api.call "GET", "/api/problems"
    .done (resp) =>
      @setState update @state,
        $set: problems: resp.data

  componentWillMount: ->
    @onProblemChange()

  render: ->

    problemView = React.cloneElement @props.children,
      key: document.location.pathname
      problems: @state.problems
      onProblemChange: @onProblemChange

    <Grid fluid={true}>
      <Col xs={3}>
        <ProblemExplorer problems={@state.problems}/>
      </Col>
      <Col xs={9}>
        {problemView}
      </Col>
    </Grid>

module.exports = ProblemPage
