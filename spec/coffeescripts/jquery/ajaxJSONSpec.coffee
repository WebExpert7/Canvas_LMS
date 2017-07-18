#
# Copyright (C) 2014 - present Instructure, Inc.
#
# This file is part of Canvas.
#
# Canvas is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, version 3 of the License.
#
# Canvas is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along
# with this program. If not, see <http://www.gnu.org/licenses/>.

define [
  'INST'
  'jquery'
  'jquery.ajaxJSON'
], (INST, $) ->

  storedInstEnv = null

  QUnit.module '$.fn.defaultAjaxError',
    setup: ->
      storedInstEnv = INST.environment
      $.ajaxJSON.unhandledXHRs = []

    teardown: ->
      INST.environment = storedInstEnv

  test 'should call the function if not production', ->
    notEqual INST.environment, 'production'
    deepEqual $.ajaxJSON.unhandledXHRs, []

    spy = @spy()
    $("#fixtures").defaultAjaxError(spy)
    xhr = {status: 200, responseText: '{"status": "ok"}'}
    $.fn.defaultAjaxError.func({}, xhr)
    ok spy.called

  test 'should call the function if unhandled', ->
    INST.environment = 'production'
    xhr = {status: 400, responseText: '{"status": "ok"}'}
    $.ajaxJSON.unhandledXHRs.push(xhr)

    spy = @spy()
    $("#fixtures").defaultAjaxError(spy)
    $.fn.defaultAjaxError.func({}, xhr)
    ok spy.called

  test 'should call the function if unauthenticated', ->
    INST.environment = 'production'
    deepEqual $.ajaxJSON.unhandledXHRs, []

    spy = @spy()
    $("#fixtures").defaultAjaxError(spy)
    xhr = {status: 401, responseText: '{"status": "unauthenticated"}'}
    $.fn.defaultAjaxError.func({}, xhr)
    ok spy.called


  QUnit.module '$.ajaxJSON.isUnauthenticated'

  test 'returns false if status is not 401', ->
    equal $.ajaxJSON.isUnauthenticated({status: 200}), false

  test 'returns false if status is 401 but the message is not unauthenticated', ->
    xhr = {status: 401, responseText: ''}
    equal $.ajaxJSON.isUnauthenticated(xhr), false

  test 'returns false if status is 401 but the message is not unauthenticated', ->
    xhr = {status: 401, responseText: '{"status": "unauthorized"}'}
    equal $.ajaxJSON.isUnauthenticated(xhr), false

  test 'returns true if status is 401 and message is unauthenticated', ->
    xhr = {status: 401, responseText: '{"status": "unauthenticated"}'}
    equal $.ajaxJSON.isUnauthenticated(xhr), true
