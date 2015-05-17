class OrdersController < ApplicationController

def destroy
  current_order.destroy
  session[:order_id] = nil
  redirect_to root_path, :notice => "Basket emptied successfully."
end

def checkout
    @order = Shoppe::Order.find(current_order.id)
    
    
    if request.patch?
      @order.attributes = params[:order].permit(:first_name, :last_name, :company, :billing_address1, :billing_address2, :billing_address3, :billing_address4, :billing_country_id, :billing_postcode, :email_address, :phone_number, :delivery_name, :delivery_address1, :delivery_address2, :delivery_address3, :delivery_address4, :delivery_postcode, :delivery_country_id, :separate_delivery_address)
      @order.ip_address = request.ip
      if @order.proceed_to_confirm
        redirect_to checkout_payment_path
      end
    else
      # Add some example order data for the example. In a real application
      # this shouldn't be present.
      Faker::Config.locale = 'en-GB'
      @order.first_name = Faker::Name.first_name                                            if @order.first_name.blank?
      @order.last_name = Faker::Name.last_name                                              if @order.last_name.blank?
      @order.company = Faker::Company.name                                                  if @order.company.blank?
      @order.email_address = Faker::Internet.email                                          if @order.email_address.blank?
      @order.phone_number = Faker::PhoneNumber.phone_number                                 if @order.phone_number.blank?
      @order.billing_address1 = Faker::Address.building_number + " " + Faker::Address.street_name   if @order.billing_address1.blank?
      @order.billing_address3 = Faker::Address.city                                                 if @order.billing_address3.blank?
      @order.billing_address4 = Faker::Address.county                                               if @order.billing_address4.blank?
      @order.billing_postcode = Faker::Address.zip                                                  if @order.billing_postcode.blank?
    end
  end

def payment
  if request.post?
    redirect_to checkout_confirmation_path
  end
end

def confirmation
  if request.post?
    current_order.confirm!
    session[:order_id] = nil
    redirect_to root_path, :notice => "Order has been placed successfully!"
  end
end
end
