// Generated by CoffeeScript 1.12.6
var load_scoreboard, load_teamscore, renderScoreboard, renderScoreboardTabs, renderScoreboardTeamScore;

renderScoreboardTeamScore = _.template($("#scoreboard-teamscore-template").remove().text());

renderScoreboardTabs = _.template($("#scoreboard-tabs-template").remove().text());

renderScoreboard = _.template($("#scoreboard-template").remove().text());

load_teamscore = function() {
  return apiCall("GET", "/api/team", {}).done(function(resp) {
    switch (resp["status"]) {
      case 1:
        return $("#scoreboard-teamscore").html(renderScoreboardTeamScore({
          teamscore: resp.data.score
        }));
      case 0:
        return apiNotify(resp);
    }
  });
};

this.reloadGraph = function() {
  var reload;
  reload = function() {
    var active_gid, active_tab;
    $(".progression-graph").empty();
    active_tab = $("ul#scoreboard-tabs li.active").data();
    if (active_tab !== void 0) {
      active_gid = active_tab.gid;
      return window.drawTopTeamsProgressionGraph("#" + active_gid + "-progression", active_gid);
    }
  };
  return setTimeout(reload, 100);
};

load_scoreboard = function() {
  return apiCall("GET", "/api/stats/scoreboard", {}).done(function(resp) {
    switch (resp["status"]) {
      case 1:
        $("#scoreboard-tabs").html(renderScoreboardTabs({
          data: resp.data,
          renderScoreboard: renderScoreboard
        }));
        return reloadGraph();
      case 0:
        return apiNotify(resp);
    }
  });
};

$(function() {
  load_scoreboard();
  return load_teamscore();
});
