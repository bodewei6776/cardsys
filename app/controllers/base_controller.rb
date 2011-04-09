class BaseController < ApplicationController

  def change_catena
    respond_to do |format|
      format.json {
        Catena.current = Catena.find(params[:id])
        render :inline => "true"
      }
    end
  end
end
