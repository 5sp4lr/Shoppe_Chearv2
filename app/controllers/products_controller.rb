class ProductsController < ApplicationController

  def index
    @products = Shoppe::Product.root.ordered.includes(:product_category, :variants)
    @products = @products.group_by(&:product_category)
    @q = Shoppe::Product.ransack(params[:q])
    @product = @q.result(distinct: true)
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

end
