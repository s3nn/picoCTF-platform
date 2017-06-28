React = require 'react'
ReactDOM = require 'react-dom'

LinkedStateMixin = require 'react-addons-linked-state-mixin'

Link = (require "react-router").Link
History = (require "react-router").History

classNames = require 'classnames'

RB = require 'react-bootstrap'

Glyphicon = RB.Glyphicon
Panel = RB.Panel
Input = RB.Input
Row = RB.Row
Col = RB.Col
Button = RB.Button
Grid = RB.Grid
Badge = RB.Badge

Api = require "../utils/api"

update = require 'react-addons-update'

_ = require 'underscore'

ShowIf = (require "../utils/react_helper").ShowIf

Problem = React.createClass
  mixins: [LinkedStateMixin]

  propTypes: ->
    name: React.PropTypes.string.isRequired
    description: React.PropTypes.string.isRequired
    score: React.PropTypes.number.isRequired
    author: React.PropTypes.string.isRequired

  getInitialState: ->
    key: ""

  makeHeader: ->
    <div>
      <Link to={"/problems/#{@props.pid}"}>
        <strong>{@props.name}</strong> {@props.score}
      </Link>
      <span className="pull-right">
        <Link to={"/problems/category/#{@props.category}"}>
          <Badge>{@props.category}</Badge>
        </Link>
      </span>
    </div>

  makeFooter: ->
    <div>
      <span>Written by {@props.author} at {@props.organization}</span>
      <span className="pull-right"><strong>Solves: {@props.solves}</strong></span>
    </div>

  onProblemSubmit: (e) ->
    e.preventDefault()
    Api.call "POST", "/api/problems/submit", {pid: @props.pid, key: @state.key}
    .done (resp) =>
      Api.notify resp
      @setState update @state, key: $set: ""
      @props.onProblemChange @props.pid

  render: ->
    problemClass = classNames(
      "panel-info": !@props.solved
      "panel-success": @props.solved
    )

    <Panel className={problemClass} header={@makeHeader()} footer={@makeFooter()}>
      <div dangerouslySetInnerHTML={__html: @props.description}/>
      <hr/>
      <ShowIf truthy={@props.solved}>
        <Input type="text" bsStyle="success" hasFeedback disabled/>
      </ShowIf>
      <ShowIf truthy={!@props.solved}>
        <form onSubmit={@onProblemSubmit}>
          <Input type="text"
            buttonBefore={<Button type="submit">Submit</Button>}
            valueLink={@linkState "key"}/>
        </form>
      </ShowIf>
    </Panel>

module.exports = Problem
