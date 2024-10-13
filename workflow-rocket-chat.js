/**
 * This is a template for an on-change rule. This rule defines what
 * happens when a change is applied to an issue.
 *
 * For details, read the Quick Start Guide:
 * https://www.jetbrains.com/help/youtrack/server/2023.1/Quick-Start-Guide-Workflows-JS.html
 */

const entities = require('@jetbrains/youtrack-scripting-api/entities');
const http = require('@jetbrains/youtrack-scripting-api/http');

exports.rule = entities.Issue.onChange({
  title: 'Sends message when new issue is created to Rocket-notify',
  action: (ctx) => {
    const issue = ctx.issue;
    const connection = new http.Connection('https://rocket.chat.domain/hooks/EKne9N3tMu2vN8KKA/s9YidCpXeLbK7CHAsBAvDkNSxuhpvLG4JjevkHLJuAk4s3kd', null, 2000);
    connection.addHeader('Content-Type', 'application/json');
 
    let xsprints =  "";

    connection.postSync('', null, JSON.stringify({ text: 'Issue Update: ' + issue.summary + " assignee:" + issue.assignee + " https://issues.crtsrv.se/issue/" + issue.id }));
  },
  requirements: {
    // TODO: add requirements
  }
});
