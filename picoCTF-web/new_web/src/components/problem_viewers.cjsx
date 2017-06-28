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
Pagination = RB.Pagination

Breadcrumb = RB.Breadcrumb
BreadcrumbItem = RB.BreadcrumbItem

update = require 'react-addons-update'

_ = require 'underscore'

Problem = require './problem'

ReactHelper = require "../utils/react_helper"
ShowIf = ReactHelper.ShowIf

ViewerToolbar = React.createClass
  mixins: [History]

  propTypes:
    filteredProblems: React.PropTypes.array.isRequired
    problemPages: React.PropTypes.number.isRequired
    activePage: React.PropTypes.number.isRequired
    handlePageSelect: React.PropTypes.func.isRequired

  render: ->

    if @props.filteredProblems.length > 0
      firstProblem = _.first @props.filteredProblems

      <Row>
        <Col xs={5} style={marginLeft: "-15px"}>
          <Breadcrumb className="pull-left">
            <BreadcrumbItem onClick={() => @history.push "/problems"}>
              Problems
            </BreadcrumbItem>

            <BreadcrumbItem onClick={() => @history.push "/problems/category/#{firstProblem.category}"}>
              {firstProblem.category}
            </BreadcrumbItem>

            <ShowIf truthy={@props.filteredProblems.length == 1}>
              <BreadcrumbItem active>
                {firstProblem.name}
              </BreadcrumbItem>
            </ShowIf/>

          </Breadcrumb>
        </Col>
        <Col xsOffset={2} xs={5}>
          <ShowIf truthy={@props.problemPages > 1}>
            <Pagination first next prev last ellipsis
              id="problem-pagination"
              className="pull-right"
              maxButtons={5}
              items={@props.problemPages}
              activePage={@props.activePage}
              onSelect={@props.handlePageSelect}/>
          </ShowIf>
        </Col>
      </Row>
    else
      <div/>

Viewer = React.createClass

  problemsPerPage: 4

  propTypes:
    problems: React.PropTypes.array.isRequired
    showFilter: React.PropTypes.func.isRequired

  getInitialState: ->
    activePage: 1

  handlePageSelect: (e, selectedEvent) ->
    @setState
      activePage: selectedEvent.eventKey

  render: ->
    filteredProblems = @props.showFilter @props.problems

    problemPages = parseInt (filteredProblems.length / @problemsPerPage)

    activeIndex = @state.activePage - 1
    startOfPage = activeIndex * @problemsPerPage
    shownProblems = filteredProblems.slice startOfPage, startOfPage + @problemsPerPage

    <div>
      <ViewerToolbar
        handlePageSelect={@handlePageSelect}
        activePage={@state.activePage}
        filteredProblems={filteredProblems}
        problemPages={problemPages}
        {...@props}/>

      <Row id="problem-list">
        {_.map shownProblems, (problem) =>
          <Problem
            key={problem.pid}
            onProblemChange={@props.onProblemChange}
            {...problem}/>}
      </Row>
    </div>

ProblemViewer = React.createClass
  showProblemFilter: (problems) ->
    _.filter problems, (problem) =>
      problem.pid == @props.params.pid

  render: ->
    <Viewer showFilter={@showProblemFilter} {...@props}/>

DefaultProblemViewer = React.createClass
  render: ->
    <Viewer showFilter={_.identity} {...@props}/>

CategoryViewer = React.createClass
  showCategoryFilter: (problems) ->
    _.filter problems, (problem) =>
      problem.category == @props.params.category

  render: ->
    <Viewer showFilter={@showCategoryFilter} {...@props}/>

module.exports =
  DefaultProblemViewer: DefaultProblemViewer
  CategoryViewer: CategoryViewer
  ProblemViewer: ProblemViewer
