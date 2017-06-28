React = require 'react'
ReactDOM = require 'react-dom'

History = (require "react-router").History
Link = (require "react-router").Link

RB = require 'react-bootstrap'

Glyphicon = RB.Glyphicon
Panel = RB.Panel
Input = RB.Input
Row = RB.Row
Col = RB.Col
Button = RB.Button
Grid = RB.Grid
Popover = RB.Popover
Overlay = RB.Overlay

Typeahead = require "./reasonable_typeahead"

update = require 'react-addons-update'

_ = require 'underscore'

classNames = require 'classnames'

ProblemItem = React.createClass

  propTypes:
    name: React.PropTypes.string.isRequired
    description: React.PropTypes.string.isRequired
    score: React.PropTypes.number.isRequired

  render: ->
    problemItemClass = classNames(
      "problem-item": true,
      "bg-success": @props.solved,
      "bg-info": @props.unlocked && !@props.solved,
      "problem-item-locked": !@props.unlocked
    )

    #Bind to this particular problem
    showProblemPreview = _.partial @props.previewTriggers.showProblemPreview, @props
    hideProblemPreview = _.partial @props.previewTriggers.hideProblemPreview, @props

    <Link className="problem-item-container" to={"/problems/#{@props.pid}"}>
      <div className={problemItemClass}
      onMouseEnter={showProblemPreview}
      onMouseLeave={hideProblemPreview}/>
    </Link>

ProblemCategory = React.createClass
  propTypes:
    category: React.PropTypes.string.isRequired
    problems: React.PropTypes.array.isRequired

  render: ->
    <div>
      <h3 className="problem-category">
        <Link to={"/problems/category/#{@props.category}"}>{@props.category}</Link>
      </h3>
      {_.map _.sortBy(@props.problems, "score"), (problem) =>
       <ProblemItem key={problem.name} {...@props} {...problem}/>}
    </div>

ProblemPopover = React.createClass
  render: ->
    popoverTitle = <span><strong>{@props.name}</strong> {@props.score} <span className="pull-right">Solves: {@props.solves}</span></span>

    <Popover {...@props} id="problem-preview" title={popoverTitle}>
      <div dangerouslySetInnerHTML={__html: @props.description}/>
    </Popover>

ProblemExplorer = React.createClass

  mixins: [History]

  propTypes:
    problems: React.PropTypes.array.isRequired

  getInitialState: ->
    overlay:
      problem: {}
      show: false
      target: null

  showProblemPreview: (problem, e) ->
    @setState update @state,
      overlay: $set: {problem: problem, show: true, target: e.target}

  hideProblemPreview: (problem, e) ->
    @setState update @state,
      overlay: $set: {problem: problem, show: false, target: e.target}

  onProblemSelect: (problemName) ->
    problem = _.find @props.problems, (problem) -> problem.name == problemName
    @history.push "/problems/#{problem.pid}"

  render: ->
    problemCategories = _.groupBy @props.problems, "category"

    previewTriggers =
      showProblemPreview: @showProblemPreview
      hideProblemPreview: @hideProblemPreview

    <div>
      <Panel>
        <div>
          <h3 ref="problemHeading">
              <Link to="/problems">Problems</Link>
          </h3>
          <Typeahead
            options={_.map @props.problems, "name"}
            onOptionSelected={@onProblemSelect}/>
        </div>
      </Panel>
      <Panel>
        {_.map problemCategories, (problems, category) ->
          <ProblemCategory key={category} ref="problemPanel"
            previewTriggers={previewTriggers}
            category={category} problems={problems}/>}
      </Panel>
      <Overlay
        show={@state.overlay.show}
        placement="right"
        container={this}
        target={() => ReactDOM.findDOMNode @refs.problemHeading}
        containerPadding={20}
      >
        <ProblemPopover {...@state.overlay.problem}/>
      </Overlay>
    </div>

module.exports = ProblemExplorer
