class CategoriesController < ApplicationController
  before_filter :load_category, :only => [:show, :edit, :update, :destroy]

  def index
    @categories = Category.all
  end

  def show
  end

  def new
    @category = Category.new
    @roots = Category.roots
  end

  def edit
  end

  def create
    @category = Category.new(params[:category])

    respond_to do |format|
      if @category.save
        format.html { redirect_to(categories_path, :notice => '分类创建成功.') }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update
    respond_to do |format|
      if @category.update_attributes(params[:category])
        format.html { redirect_to(categories_path, :notice => '分类修改成功.') }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @category.destroy
    redirect_to categories_url
  end
end
