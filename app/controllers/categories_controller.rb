# -*- encoding : utf-8 -*-
class CategoriesController < ApplicationController
  before_filter :load_category, :only => [:show, :edit, :update, :destroy]

  def index
    @categories = Category.all
  end


  def new
    @category = Category.new
    @roots = Category.roots
  end


  def create
    @category = Category.new(params[:category])

    if @category.save
      redirect_to(categories_path, :notice => '分类创建成功.') 
    else
      render :action => "new" 
    end
  end

  def update
    if @category.update_attributes(params[:category])
      redirect_to(categories_path, :notice => '分类修改成功.') 
    else
      render :action => "edit" 
    end
  end

  def destroy
    @category.destroy
    redirect_to categories_url
  end

  def load_category
    @category = Category.find(params[:id])
    
  end
end
