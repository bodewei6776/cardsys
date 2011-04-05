class LogsController < ApplicationController
  layout 'main'
  def index
    @logs = Log.paginate(default_paginate_options)
  end
end
