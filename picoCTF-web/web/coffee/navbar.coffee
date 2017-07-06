apiOffline =
  News: "/news"
  About: "/about"
  Rules: "/rules"

teacherLoggedIn =
  Problems: "/problems"
  #Shell: "/shell"
  Scoreboard: "/scoreboard"
  #Classroom: "/classroom"
  News: "/news"
  About: "/about"
  Rules: "/rules"

teacherLoggedInNoCompetition =
  #Classroom: "/classroom"
  News: "/news"
  About: "/about"
  Rules: "/rules"

userLoggedIn =
  Problems: "/problems"
  #Shell: "/shell"
  Scoreboard: "/scoreboard"
  News: "/news"
  About: "/about"
  Rules: "/rules"

userLoggedInNoCompetition =
  Scoreboard: "/scoreboard"
  News: "/news"
  About: "/about"
  Rules: "/rules"


userNotLoggedIn =
  News: "/news"
  About: "/about"
  Rules: "/rules"

adminLoggedIn =
  Management: "/management"

loadNavbar = (renderNavbarLinks, renderNestedNavbarLinks) ->

  navbarLayout = {
    renderNavbarLinks: renderNavbarLinks,
    renderNestedNavbarLinks: renderNestedNavbarLinks
  }

  apiCall "GET", "/api/user/status", {}
  .done (data) ->
    navbarLayout.links = userNotLoggedIn
    navbarLayout.status = data.data
    navbarLayout.topLevel = true
    if data["status"] == 1
      if not data.data["logged_in"]
        $(".show-when-logged-out").css("display", "inline-block")
      if data.data["teacher"]
        if data.data["competition_active"]
           navbarLayout.links = teacherLoggedIn
        else
           navbarLayout.links = teacherLoggedInNoCompetition
      else if data.data["logged_in"]
         if data.data["competition_active"]
            navbarLayout.links = userLoggedIn
         else
            navbarLayout.links = userLoggedInNoCompetition

        if data.data["admin"]
           $.extend navbarLayout.links, adminLoggedIn

    $("#navbar-links").html renderNavbarLinks(navbarLayout)
    $("#navbar-item-logout").on("click", logout)

  .fail ->
    navbarLayout.links = apiOffline
    $("#navbar-links").html renderNavbarLinks(navbarLayout)

$ ->
  renderNavbarLinks = _.template($("#navbar-links-template").remove().text())
  renderNestedNavbarLinks = _.template($("#navbar-links-dropdown-template").remove().text())

  loadNavbar(renderNavbarLinks, renderNestedNavbarLinks)
