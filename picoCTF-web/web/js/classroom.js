// Generated by CoffeeScript 1.12.6
var createGroup, createGroupSetup, deleteGroup, groupRequest, loadGroupInfo, loadGroupOverview, renderGroupInformation, renderTeamSelection;

renderGroupInformation = _.template($("#group-info-template").remove().text());

renderTeamSelection = _.template($("#team-selection-template").remove().text());

this.groupListCache = [];

String.prototype.hashCode = function() {
  var char, hash, i, j, ref;
  hash = 0;
  for (i = j = 0, ref = this.length; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
    char = this.charCodeAt(i);
    hash = ((hash << 5) - hash) + char;
    hash = hash & hash;
  }
  return hash;
};

createGroupSetup = function() {
  var formDialogContents;
  formDialogContents = _.template($("#new-group-template").html())({});
  return formDialog(formDialogContents, "Create a New Class", "OK", "new-group-name", function() {
    return createGroup($('#new-group-name').val());
  });
};

this.exportProblemCSV = function(groupName, teams) {
  return apiCall("GET", "/api/admin/problems").done((function(resp) {
    var csvData, data, problems;
    if (resp.status === 0) {
      return apiNotify(resp);
    } else {
      problems = _.filter(resp.data.problems, function(problem) {
        return !problem.disabled;
      });
      data = [
        ["Username", "First Name", "Last Name"].concat(_.map(problems, function(problem) {
          return problem.name;
        }), ["Total"])
      ];
      _.each(teams, (function(team) {
        var member, teamData;
        member = team.members[0];
        teamData = [member.username, member.firstname, member.lastname];
        teamData = teamData.concat(_.map(problems, (function(problem) {
          var solved;
          solved = _.find(team.solved_problems, function(solvedProblem) {
            return solvedProblem.name === problem.name;
          });
          if (solved) {
            return problem.score;
          } else {
            return 0;
          }
        })));
        teamData = teamData.concat([team.score]);
        return data.push(teamData);
      }));
      csvData = (_.map(data, function(fields) {
        return fields.join(",");
      })).join("\n");
      return download(csvData, groupName + ".csv", "text/csv");
    }
  }));
};

loadGroupOverview = function(groups, showFirstTab, callback) {
  $("#group-overview").html(renderGroupInformation({
    data: groups
  }));
  $("#new-class-tab").on("click", function(e) {
    return createGroupSetup();
  });
  $("#new-class-button").on("click", function(e) {
    return createGroupSetup();
  });
  $("#class-tabs").on('shown.bs.tab', 'a[data-toggle="tab"]', function(e) {
    var groupName, tabBody;
    tabBody = $(this).attr("href");
    groupName = $(this).data("group-name");
    return apiCall("GET", "/api/group/member_information", {
      gid: $(this).data("gid")
    }).done(function(teamData) {
      var group, j, len;
      ga('send', 'event', 'Group', 'LoadTeacherGroupInformation', 'Success');
      for (j = 0, len = groups.length; j < len; j++) {
        group = groups[j];
        if (group.name === groupName) {
          $(tabBody).html(renderTeamSelection({
            teams: teamData.data,
            groupName: groupName,
            owner: group.owner,
            gid: group.gid
          }));
        }
      }
      return $(".team-visualization-enabler").on("click", function(e) {
        var k, len1, preparedData, ref, results, team, tid;
        tid = $(e.target).data("tid");
        ref = teamData.data;
        results = [];
        for (k = 0, len1 = ref.length; k < len1; k++) {
          team = ref[k];
          if (tid === team.tid) {
            preparedData = {
              status: 1,
              data: team.progression
            };
            window.renderTeamProgressionGraph("#visualizer-" + tid, preparedData);
            results.push(_.delay(window.renderTeamRadarGraph, 150, "#radar-visualizer-" + tid, tid));
          } else {
            results.push(void 0);
          }
        }
        return results;
      });
    });
  });
  if (showFirstTab) {
    $('#class-tabs a:first').tab('show');
  }
  $("ul.nav-tabs a").click((function(e) {
    e.preventDefault();
    return $(this).tab('show');
  }));
  $("#group-request-form").on("submit", groupRequest);
  $(".delete-group-span").on("click", function(e) {
    return deleteGroup($(e.target).data("group-name"));
  });
  if (callback) {
    return callback();
  }
};

loadGroupInfo = function(showFirstTab, callback) {
  return apiCall("GET", "/api/group/list", {}).done(function(data) {
    switch (data["status"]) {
      case 0:
        apiNotify(data);
        return ga('send', 'event', 'Group', 'GroupListLoadFailure', data.message);
      case 1:
        window.groupListCache = data.data;
        return loadGroupOverview(data.data, showFirstTab, callback);
    }
  });
};

createGroup = function(groupName) {
  return apiCall("POST", "/api/group/create", {
    "group-name": groupName
  }).done(function(data) {
    if (data['status'] === 1) {
      closeDialog();
      ga('send', 'event', 'Group', 'CreateGroup', 'Success');
      apiNotify(data);
      return loadGroupInfo(false, function() {
        return $('#class-tabs li:eq(-2) a').tab('show');
      });
    } else {
      ga('send', 'event', 'Group', 'CreateGroup', 'Failure::' + data.message);
      return apiNotifyElement($("#new-group-name"), data);
    }
  });
};

deleteGroup = function(groupName) {
  return confirmDialog("You are about to permanently delete this class. This will automatically remove your students from this class. Are you sure you want to delete this class?", "Class Confirmation", "Delete Class", "Cancel", function() {
    return apiCall("POST", "/api/group/delete", {
      "group-name": groupName
    }).done(function(data) {
      apiNotify(data);
      if (data['status'] === 1) {
        ga('send', 'event', 'Group', 'DeleteGroup', 'Success');
        return loadGroupInfo(true);
      } else {
        return ga('send', 'event', 'Group', 'DeleteGroup', 'Failure::' + data.message);
      }
    });
  }, function() {
    return ga('send', 'event', 'Group', 'DeleteGroup', 'RejectPrompt');
  });
};

groupRequest = function(e) {
  var groupName;
  e.preventDefault();
  groupName = $("#group-name-input").val();
  return createGroup(groupName);
};

$(function() {
  if (!window.userStatus) {
    apiCall("GET", "/api/user/status").done(function() {
      if (!window.userStatus.teacher) {
        return apiNotify({
          status: 1,
          message: "You are no longer a teacher."
        }, "/profile");
      }
    });
  } else if (!window.userStatus.teacher) {
    apiNotify({
      status: 1,
      message: "You are no longer a teacher."
    }, "/profile");
  }
  loadGroupInfo(true);
  $(document).on('shown.bs.tab', 'a[href="#group-overview-tab"]', function() {
    return loadGroupInfo(true);
  });
});
