class ProductsController < ApplicationController

  before_filter do
    if params[:category_id]
      @product_category = Shoppe::ProductCategory.where(:permalink => params[:category_id]).first!
    end
    if @product_category && params[:product_id]
      @product = @product_category.products.where(:permalink => params[:product_id]).active.first!      
    end
  end

  def index
    @products = Shoppe::Product.root.ordered.includes(:product_category, :variants)
    @products = @products.group_by(&:product_category)
    @search = Shoppe::Product.search(params[:q])
    @product = @search.result.includes(:product_category).page(params[:page]).to_a.uniq
  end

  def filter
    @products = Shoppe::Product.active.with_attributes(params[:key].to_s, params[:value].to_s)
  end

  def show
    @product = Shoppe::Product.find_by_permalink(params[:permalink])
    @attributes = @product.product_attributes.public.to_a
  end
  
  def buy
  @product = Shoppe::Product.find_by_permalink!(params[:permalink])
  current_order.order_items.add_item(@product, 1)
  redirect_to product_path(@product.permalink), :notice => "Product has been added successfuly!"
  end

  def add_to_basket
    product_to_order = params[:variant] ? @product.variants.find(params[:variant].to_i) : @product
    current_order.order_items.add_item(product_to_order, params[:quantity].blank? ? 1 : params[:quantity].to_i)
    respond_to do |wants|
      wants.html { redirect_to request.referer }
      wants.json { render :json => {:added => true} }
    end
  rescue Shoppe::Errors::NotEnoughStock => e
    respond_to do |wants|
      wants.html { redirect_to request.referer, :alert => "We're sorry but we don't have enough stock to add that many products. We currently have #{e.available_stock} item(s) in stock. Please try again."}
      wants.json { render :json => {:error => 'NotEnoughStock', :available_stock => e.available_stock}}
    end
  end

end
