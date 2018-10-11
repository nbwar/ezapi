# Dependencies
require 'active_support/core_ext/string/inflections'
require 'active_support/json'
require 'active_support/core_ext/object/json'

# Main
require "ezapi/version"
require "ezapi/errors"
require "ezapi/utils"
require "ezapi/client"
require "ezapi/dsl"
require "ezapi/object_base"

# Actions
require "ezapi/actions/show"
require "ezapi/actions/save"
require "ezapi/actions/create"
require "ezapi/actions/delete"
require "ezapi/actions/update"
require "ezapi/actions/index"

module EZApi
end
