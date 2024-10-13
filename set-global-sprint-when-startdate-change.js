var entities = require('@jetbrains/youtrack-scripting-api/entities');

exports.rule = entities.Issue.onChange({
  title: 'Set Global Sprint that is with-in start and release date depending on set StartDate',
  guard: (ctx) => {
    return ctx.issue.fields.isChanged(ctx.StartDateDate);
  },
  action: (ctx) => {
    var issue = ctx.issue;

    var startDate = issue.fields["Start Date"];
    console.log("Current Start Date: " + startDate);
    var globalSprint = issue.fields["global sprint"];
    globalSprint.forEach(function(sprint){
          console.log("Current global sprint: " + sprint.name)
    })
   
    var globalSprints = ctx.globalsprintVersionMulti;
    globalSprints.values.forEach(function (v) {
      if(startDate >= v.startDate && startDate < v.releaseDate){
        console.log("Found matching global sprint: " + v.name);
        globalSprint.clear();
        globalSprint.add(v);
        return;
      }
    })


   
  },
  requirements: {
    StartDateDate: {
      name: "Start Date",
      type: entities.Field.dateType
    },
    globalsprintVersionMulti: {
      name: "global sprint",
      type: entities.ProjectVersion.fieldType,
      multi: true
    }
    }
  }
)
