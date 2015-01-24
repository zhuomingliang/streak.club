
SubmissionList = require "widgets.submission_list"

WelcomeBanner = require "widgets.welcome_banner"

class ViewSubmission extends require "widgets.base"
  @needs: {"submission", "streaks"}

  inner_content: =>
    unless @current_user
      widget WelcomeBanner

    if @submission\allowed_to_edit @current_user
      div class: "admin_tools", ->
        a href: @url_for("edit_submission", id: @submission.id), "Edit submission"
        raw " &middot; "
        a href: @url_for("delete_submission", id: @submission.id), "Delete submission"

    widget SubmissionList submissions: { @submission }, show_user: true, show_comments: true

