React = require 'react'

FrontPage = React.createClass
  render: ->
    <div>
      <p>Front Page</p>
      {JSON.stringify(@props.status)}
    </div>

module.exports = FrontPage
