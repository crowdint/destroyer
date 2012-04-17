require "destroyer/version"
require "destroyer/destroyer"

class ActiveRecord::Base
  include Destroyer
end