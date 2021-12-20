# frozen_string_literal: true
require 'csv'
class CsvGenerate

  def initialize(csv_data)
    @data = csv_data
    @row = nil
    @index = nil
  end

  def call
    @orders = Order.where(id:@data).not_in_cart
    attributes = %w{period orders sale_items sales_total invoiced refunded sales_tax sales_shipping sales_discount cancelled}
    dates = @orders.pluck(:order_date)
    orders_sum = 0
    sale_items_sum = 0
    sales_total_sum = 0
    invoiced_sum = 0
    refunded_sum = 0
    sales_tax_sum = 0
    sales_shipping_sum = 0
    sales_discount_sum = 0
    cancelled_sum = 0
    response = CSV.generate(headers: true) do |csv|
      csv << attributes
      utc_dates = dates.map{|date|date.in_time_zone('UTC')}
      utc_dates.compact.map{|a|a.to_date}.uniq.sort.reverse.each do |date|
        orders_sum = self.orders(date) + orders_sum
        sale_items_sum = self.sale_items(date) + sale_items_sum
        sales_total_sum = self.sales_total(date) + sales_total_sum
        invoiced_sum = self.invoiced(date) + invoiced_sum
        refunded_sum = self.refunded(date) + refunded_sum
        sales_tax_sum = self.sales_tax(date) + sales_tax_sum
        sales_shipping_sum = self.sales_shipping(date) + sales_shipping_sum
        sales_discount_sum = self.sales_discount(date) + sales_discount_sum
        cancelled_sum = self.cancelled(date) + cancelled_sum
        csv << attributes.map{ |att| self.send(att,date) }
      end
    end
    response << "total,#{orders_sum},#{sale_items_sum},₹#{sales_total_sum},₹#{invoiced_sum},₹#{refunded_sum},₹#{sales_tax_sum.to_f.round(2)},₹#{sales_shipping_sum},₹#{sales_discount_sum},₹#{cancelled_sum}"
    response
  end

  def period(date)
    date.to_date.strftime('%b %d, %Y')
  end

  def orders(date)
    Order.not_in_cart.where(order_date:date.in_time_zone('UTC').beginning_of_day..date.in_time_zone('UTC').end_of_day).count
  end

  def sale_items(date)
    OrderItem.where(order_id:Order.not_in_cart.where(order_date:date.in_time_zone('UTC').beginning_of_day..date.in_time_zone('UTC').end_of_day).pluck(:id)).after_placed&.sum(&:total_item_quantity) || 0.0
  end

  def sales_total(date)
    Order.after_placed.where(order_date:date.in_time_zone('UTC').beginning_of_day..date.in_time_zone('UTC').end_of_day)&.sum(:total).to_f.round(2) || 0.0
  end

  def invoiced(date)
    Order.where(order_date:date.in_time_zone('UTC').beginning_of_day..date.in_time_zone('UTC').end_of_day).where(status:"delivered")&.sum(:total).to_f.round(2) || 0.0
  end

  def refunded(date)
    Order.where(order_date:date.in_time_zone('UTC').beginning_of_day..date.in_time_zone('UTC').end_of_day).where(status:"refunded")&.sum(:total).to_f.round(2) || 0.0
  end

  def sales_tax(date)
    Order.after_placed.where(order_date:date.in_time_zone('UTC').beginning_of_day..date.in_time_zone('UTC').end_of_day)&.sum(:total_tax).to_f.round(2) || 0.0
  end

  def sales_shipping(date)
    Order.after_placed.where(order_date:date.in_time_zone('UTC').beginning_of_day..date.in_time_zone('UTC').end_of_day)&.sum(:shipping_total).to_f.round(2) || 0.0
  end

  def sales_discount(date)
      Order.after_placed.where(order_date:date.in_time_zone('UTC').beginning_of_day..date.in_time_zone('UTC').end_of_day)&.sum(:applied_discount).to_f.round(2) || 0.0
  end

  def cancelled(date)
    Order.where(order_date:date.in_time_zone('UTC').beginning_of_day..date.in_time_zone('UTC').end_of_day).where(status:"cancelled")&.sum(:total).to_f.round(2) || 0.0
  end
end
