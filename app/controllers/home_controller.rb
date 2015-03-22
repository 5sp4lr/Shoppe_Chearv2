class HomeController < ApplicationController
  def index
  	@products = Shoppe::Product.root.ordered.includes(:product_category, :variants)
    @products = @products.group_by(&:product_category)
  end
end
