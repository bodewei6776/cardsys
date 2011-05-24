class LogsController < ApplicationController
  layout 'main'
  def index
    if params[:t]
      @logs = Log.paginate(default_paginate_options.merge({:conditions => {:log_type => params[:t]}}))
    else
      @logs = Log.paginate(default_paginate_options)
    end
  end
end
