class MemberCardGrantersController < ApplicationController
  def switch
    @mg = MemberCardGranter.find(params[:id])
    @mg.enabled? ? @mg.disable! : @mg.enable!
    redirect_to granters_member_cards_path(:p => "num",:card_serial_num => @mg.member_card.card_serial_num,:member_name => @mg.member_card.member.name) 
  end
end
