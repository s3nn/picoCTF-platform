React = require 'react'
ReactDom = require 'react-dom'

ReactRouter = require 'react-router'
Router = ReactRouter.Router
Route = ReactRouter.Route
IndexRoute = ReactRouter.IndexRoute

createBrowserHistory = require "history/lib/createBrowserHistory"

#Chrome dev-tools
@React = React

App = require './app'
FrontPage = require './views/front_page'
UserRegistrationPage = require './views/user_registration_page'
UserLoginPage = require "./views/user_login_page"
UserLogoutPage = require "./views/user_logout_page"

ProblemPage = require "./views/problem_page"
ProblemViewers = require "./components/problem_viewers"

ShellPage = require "./views/shell_page"
ShellViewers = require "./components/shell_viewers"

AccountPage = require "./views/account_page"

ReactDom.render (
  <Router history={createBrowserHistory()}>
    <Route path="/" component={App}>
      <Route path="login" component={UserLoginPage}/>
      <Route path="logout" component={UserLogoutPage}/>
      <Route path="register" component={UserRegistrationPage}/>
      <Route path="problems" component={ProblemPage}>
        <IndexRoute component={ProblemViewers.DefaultProblemViewer}/>
        <Route path="category/:category" component={ProblemViewers.CategoryViewer}/>
        <Route path=":pid" component={ProblemViewers.ProblemViewer}/>
      </Route>
      <Route path="shell" component={ShellPage}>
        <IndexRoute component={ShellViewers.DefaultShellViewer}/>
        <Route path=":sid" component={ShellViewers.ShellViewer}/>
      </Route>
      <Route path="account" component={AccountPage}/>
      <IndexRoute component={FrontPage}/>
    </Route>
  </Router>
), document.getElementById 'app'

