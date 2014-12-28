
lapis = require "lapis"

import respond_to, capture_errors, assert_error from require "lapis.application"
import assert_valid from require "lapis.validate"
import trim_filter, slugify from require "lapis.util"

import Users from require "models"

import not_found from require "helpers.app"

class UsersApplication extends lapis.Application
  [user_profile: "/u/:slug"]: capture_errors {
    on_error: => not_found
    =>
      @user = assert_error Users\find(slug: slugify @params.slug), "invalid user"
      render: true
  }

  [user_register: "/register"]: respond_to {
    GET: => render: true

    POST: capture_errors =>
      -- assert_csrf @ TODO
      trim_filter @params

      assert_valid @params, {
        { "username", exists: true, min_length: 2, max_length: 25 }
        { "password", exists: true, min_length: 2 }
        { "password_repeat", equals: @params.password }
        { "email", exists: true, min_length: 3 }
      }

      user = assert_error Users\create {
        username: @params.username
        email: @params.email
        password: @params.password
      }

      user\write_session @

      json: { success: true }

  }

  [user_login: "/login"]: respond_to {
    GET: => render: true
    POST: capture_errors =>
      -- assert_csrf @
      assert_valid @params, {
        { "username", exists: true }
        { "password", exists: true }
      }

      user = assert_error Users\login @params.username, @params.password
      user\write_session @

      @session.flash = "Welcome back!"
      redirect_to: @params.return_to or @url_for("index")

  }