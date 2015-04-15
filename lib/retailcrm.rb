# encoding: utf-8

require 'net/http'
require 'net/https'
require 'uri'
require 'json'

# RetailCRM API Client
class Retailcrm

  def initialize(url, key)
    @version = 3
    @url = "#{url}/api/v#{@version}/"
    @key = key
    @params = { :apiKey => @key }
    @filter = nil
    @ids = nil
  end

  ##
  # === Get orders by filter
  # http://www.retailcrm.ru/docs/Разработчики/СправочникМетодовAPIV3
  #
  # Example:
  #  >> Retailcrm.orders({:email => 'test@example.com', :status => 'new'}, 50, 2)
  #  => {...}
  #
  # Arguments:
  #   filter (Hash)
  #   limit (Integer) (20|50|100)
  #   page (Integer)
  def orders(filter = nil, limit = 20, page = 1)
    url = "#{@url}orders"
    @params[:limit] = limit
    @params[:page] = page
    @filter = filter.to_a.map { |x| "filter[#{x[0]}]=#{x[1]}" }.join("&")
    make_request(url)
  end

  ##
  # === Get orders statuses
  # http://www.retailcrm.ru/docs/Разработчики/СправочникМетодовAPIV3
  #
  # Example:
  #  >> Retailcrm.orders_statuses([26120, 19282])
  #  => {...}
  #
  # Arguments:
  #   ids (Array)
  def orders_statuses(ids = [])
    @ids = ids.map { |x| "ids[]=#{x}" }.join("&")
    url = "#{@url}orders/statuses"
    make_request(url)
  end

  ##
  # ===  Get orders by id (or externalId)
  # http://www.retailcrm.ru/docs/Разработчики/СправочникМетодовAPIV3
  #
  # Example:
  #  >> Retailcrm.orders_get(345, 'id')
  #  => {...}
  #
  # Arguments:
  #   id (Integer)
  #   by (String)
  #   site (String)
  def orders_get(id, by = 'externalId', site = nil)
    url = "#{@url}orders/#{id}"
    if by != 'externalId'
      @params[:by] = by
      @params[:site] = site
    end
    make_request(url)
  end

  ##
  # ===  Create order
  # http://www.retailcrm.ru/docs/Разработчики/СправочникМетодовAPIV3
  #
  # Example:
  #  >> Retailcrm.orders_create(order)
  #  => {...}
  #
  # Arguments:
  #   order (Array)
  #   site (String)
  def orders_create(order, site = nil)
    url = "#{@url}orders/create"
    @params[:order] = order.to_json
    @params[:site] = site
    make_request(url, 'post')
  end

  ##
  # ===  Edit order
  # http://www.retailcrm.ru/docs/Разработчики/СправочникМетодовAPIV3
  #
  # Example:
  #  >> Retailcrm.orders_edit(order)
  #  => {...}
  #
  # Arguments:
  #   order (Array)
  #   site (String)
  def orders_edit(order, site = nil)
    id = order[:externalId]
    url = "#{@url}orders/#{id}/edit"
    @params[:order] = order.to_json
    @params[:site] = site
    make_request(url, 'post')
  end

  ##
  # ===  Upload orders
  # http://www.retailcrm.ru/docs/Разработчики/СправочникМетодовAPIV3
  #
  # Example:
  #  >> Retailcrm.orders_upload(orders)
  #  => {...}
  #
  # Arguments:
  #   orders (Array)
  #   site (String)
  def orders_upload(orders, site = nil)
    url = "#{@url}orders/upload"
    @params[:orders] = orders.to_json
    @params[:site] = site
    make_request(url, 'post')
  end

  ##
  # ===  Set external ids for orders created into CRM
  # http://www.retailcrm.ru/docs/Разработчики/СправочникМетодовAPIV3
  #
  # Example:
  #  >> Retailcrm.orders_fix_external_ids([{:id => 200, :externalId => 334}, {:id => 201, :externalId => 364}])
  #  => {...}
  #
  # Arguments:
  #   orders (Array)
  def orders_fix_external_ids(orders)
    url = "#{@url}orders/fix-external-ids"
    @params[:orders] = orders.to_json
    make_request(url, 'post')
  end

  ##
  # ===  Get orders history
  # http://www.retailcrm.ru/docs/Разработчики/СправочникМетодовAPIV3
  #
  # Example:
  #  >> Retailcrm.orders_history('2015-04-10 22:23:12', '2015-04-10 23:33:12')
  #  => {...}
  #
  # Arguments:
  #   start_date (Time) (Time.strftime('%Y-%m-%d %H:%M:%S'))
  #   end_date (Time) (Time.strftime('%Y-%m-%d %H:%M:%S'))
  #   limit (Integer) (20|50|100)
  #   offset (Integer)
  #   skip_my_changes (Boolean)
  def orders_history(start_date = nil, end_date = nil, limit = 100, offset = 0, skip_my_changes = true)
    url = "#{@url}orders/history"
    @params[:startDate] = start_date
    @params[:endDate] = end_date
    @params[:limit] = limit
    @params[:offset] = offset
    @params[:skipMyChanges] = skip_my_changes
    make_request(url)
  end

  ##
  # === Get orders assembly history
  # http://www.retailcrm.ru/docs/Разработчики/СправочникМетодовAPIV3
  #
  # Example:
  #  >> Retailcrm.orders_packs_history({:orderId => 26120, :startDate => '2015-04-10 23:33:12'}, 50, 2)
  #  => {...}
  #
  # Arguments:
  #   filter (Hash)
  #   limit (Integer) (20|50|100)
  #   page (Integer)
  def orders_packs_history(filter = nil, limit = 20, page = 1)
    url = "#{@url}orders/packs/history"
    @params[:limit] = limit
    @params[:page] = page
    @filter = filter.to_a.map { |x| "filter[#{x[0]}]=#{x[1]}" }.join("&")
    make_request(url)
  end

  ##
  # === Get customers by filter
  # http://www.retailcrm.ru/docs/Разработчики/СправочникМетодовAPIV3
  #
  # Example:
  #  >> Retailcrm.customers({:email => 'test@example.com'}, 50, 2)
  #  => {...}
  #
  # Arguments:
  #   filter (Hash)
  #   limit (Integer) (20|50|100)
  #   page (Integer)
  def customers(filter = nil, limit = 20, page = 1)
    url = "#{@url}customers"
    @params[:limit] = limit
    @params[:page] = page
    @filter = filter.to_a.map { |x| "filter[#{x[0]}]=#{x[1]}" }.join("&")
    make_request(url)
  end

  ##
  # ===  Get customers by id (or externalId)
  # http://www.retailcrm.ru/docs/Разработчики/СправочникМетодовAPIV3
  #
  # Example:
  #  >> Retailcrm.customers_get(345, 'id')
  #  => {...}
  #
  # Arguments:
  #   id (Integer)
  #   by (String)
  #   site (String)
  def customers_get(id, by = 'externalId', site = nil)
    url = "#{@url}customers/#{id}"
    @params[:site] = site
    if by != 'externalId'
      @params[:by] = by
    end
    make_request(url)
  end

  ##
  # ===  Create customer
  # http://www.retailcrm.ru/docs/Разработчики/СправочникМетодовAPIV3
  #
  # Example:
  #  >> Retailcrm.customer_create(customer)
  #  => {...}
  #
  # Arguments:
  #   customer (Array)
  #   site (String)
  def customers_create(customer, site = nil)
    url = "#{@url}customers/create"
    @params[:customer] = customer.to_json
    @params[:site] = site
    make_request(url, 'post')
  end

  ##
  # ===  Edit customer
  # http://www.retailcrm.ru/docs/Разработчики/СправочникМетодовAPIV3
  #
  # Example:
  #  >> Retailcrm.customers_edit(customer)
  #  => {...}
  #
  # Arguments:
  #   customer (Array)
  #   site (String)
  def customers_edit(customer, site = nil)
    id = customer[:externalId]
    url = "#{@url}customers/#{id}/edit"
    @params[:customer] = customer.to_json
    @params[:site] = site
    make_request(url, 'post')
  end

  ##
  # ===  Upload customers
  # http://www.retailcrm.ru/docs/Разработчики/СправочникМетодовAPIV3
  #
  # Example:
  #  >> Retailcrm.customers_upload(customers)
  #  => {...}
  #
  # Arguments:
  #   customers (Array)
  #   site (String)
  def customers_upload(customers, site = nil)
    url = "#{@url}customers/upload"
    @params[:customers] = customers.to_json
    @params[:site] = site
    make_request(url, 'post')
  end

  ##
  # ===  Set external ids for customers created into CRM
  # http://www.retailcrm.ru/docs/Разработчики/СправочникМетодовAPIV3
  #
  # Example:
  #  >> Retailcrm.customers_fix_external_ids([{:id => 200, :externalId => 334}, {:id => 201, :externalId => 364}])
  #  => {...}
  #
  # Arguments:
  #   customers (Array)
  def customers_fix_external_ids(customers)
    url = "#{@url}customers/fix-external-ids"
    @params[:customers] = customers.to_json
    make_request(url, 'post')
  end

  ##
  # === Get purchace prices & stock balance
  # http://www.retailcrm.ru/docs/Разработчики/СправочникМетодовAPIV3
  #
  # Example:
  #  >> Retailcrm.store_inventories({:productExternalId => 26120, :details => 1}, 50, 2)
  #  => {...}
  #
  # Arguments:
  #   filter (Hash)
  #   limit (Integer) (20|50|100)
  #   page (Integer)
  def store_inventories(filter = nil, limit = 20, page = 1)
    url = "#{@url}store/inventories"
    @params[:limit] = limit
    @params[:page] = page
    @filter = filter.to_a.map { |x| "filter[#{x[0]}]=#{x[1]}" }.join("&")
    make_request(url)
  end

  ##
  # === Set purchace prices & stock balance
  # http://www.retailcrm.ru/docs/Разработчики/СправочникМетодовAPIV3
  #
  # Example:
  #  >> Retailcrm.store_inventories_upload({:offers => [{:externalId => 123, :stores => [{:code => 'store_1', :available => 15, :purchasePrice => 1000}]}]}, :site => 'main_site')
  #  => {...}
  #
  # Arguments:
  #   offers (Array)
  #   site (String)
  def store_inventories_upload(offers = [], site = nil)
    url = "#{@url}store/inventories/upload"
    @params[:offers] = offers
    @params[:site] = site
    make_request(url, 'post')
  end

  ##
  # ===  Get delivery services
  # http://www.retailcrm.ru/docs/Разработчики/СправочникМетодовAPIV3
  #
  def delivery_services
    url = "#{@url}reference/delivery-services"
    make_request(url)
  end

  ##
  # ===  Edit delivery service
  # http://www.retailcrm.ru/docs/Разработчики/СправочникМетодовAPIV3
  #
  def delivery_services_edit(delivery_service)
    code = delivery_service[:code]
    url = "#{@url}reference/delivery-services/#{code}/edit"
    make_request(url, 'post')
  end

  # Get delivery types
  # http://www.retailcrm.ru/docs/Разработчики/СправочникМетодовAPIV3
  #
  def delivery_types
    url = "#{@url}reference/delivery-types"
    make_request(url)
  end

  ##
  # ===  Edit delivery type
  # http://www.retailcrm.ru/docs/Разработчики/СправочникМетодовAPIV3
  #
  def delivery_types_edit(delivery_type)
    code = delivery_type[:code]
    url = "#{@url}reference/delivery-types/#{code}/edit"
    make_request(url, 'post')
  end

  ##
  # ===  Get order methods
  # http://www.retailcrm.ru/docs/Разработчики/СправочникМетодовAPIV3
  #
  def order_methods
    url = "#{@url}reference/order-methods"
    make_request(url)
  end

  ##
  # ===  Edit order method
  # http://www.retailcrm.ru/docs/Разработчики/СправочникМетодовAPIV3
  #
  def order_methods_edit(order_method)
    code = order_method[:code]
    url = "#{@url}reference/order-methods/#{code}/edit"
    make_request(url, 'post')
  end

  ##
  # ===  Get order types
  # http://www.retailcrm.ru/docs/Разработчики/СправочникМетодовAPIV3
  #
  def order_types
    url = "#{@url}reference/order-types"
    make_request(url)
  end

  ##
  # ===  Edit order type
  # http://www.retailcrm.ru/docs/Разработчики/СправочникМетодовAPIV3
  #
  def order_types_edit(order_type)
    code = order_type[:code]
    url = "#{@url}reference/order-types/#{code}/edit"
    make_request(url, 'post')
  end

  # Get payment statuses
  # http://www.retailcrm.ru/docs/Разработчики/СправочникМетодовAPIV3
  #
  def payment_statuses
    url = "#{@url}reference/payment-statuses"
    make_request(url)
  end

  ##
  # ===  Edit payment status
  # http://www.retailcrm.ru/docs/Разработчики/СправочникМетодовAPIV3
  #
  def payment_statuses_edit(payment_status)
    code = payment_status[:code]
    url = "#{@url}reference/payment-statuses/#{code}/edit"
    make_request(url, 'post')
  end

  ##
  # ===  Get payment types
  # http://www.retailcrm.ru/docs/Разработчики/СправочникМетодовAPIV3
  #
  def payment_types
    url = "#{@url}reference/payment-types"
    make_request(url)
  end

  ##
  # ===  Edit payment type
  # http://www.retailcrm.ru/docs/Разработчики/СправочникМетодовAPIV3
  #
  def payment_types_edit(payment_type)
    code = payment_type[:code]
    url = "#{@url}reference/payment-type/#{code}/edit"
    make_request(url, 'post')
  end

  ##
  # ===  Get product statuses
  # http://www.retailcrm.ru/docs/Разработчики/СправочникМетодовAPIV3
  #
  def product_statuses
    url = "#{@url}reference/product-statuses"
    make_request(url)
  end

  ##
  # ===  Edit product status
  # http://www.retailcrm.ru/docs/Разработчики/СправочникМетодовAPIV3
  #
  def product_statuses_edit(product_status)
    code = product_status[:code]
    url = "#{@url}reference/product-statuses/#{code}/edit"
    make_request(url, 'post')
  end

  # Get sites list
  # http://www.retailcrm.ru/docs/Разработчики/СправочникМетодовAPIV3
  #
  def sites
    url = "#{@url}reference/sites"
    make_request(url)
  end

  ##
  # ===  Edit site
  # http://www.retailcrm.ru/docs/Разработчики/СправочникМетодовAPIV3
  #
  def sites_edit(site)
    code = site[:code]
    url = "#{@url}reference/sites/#{code}/edit"
    make_request(url, 'post')
  end

  ##
  # ===  Get status groups
  # http://www.retailcrm.ru/docs/Разработчики/СправочникМетодовAPIV3
  #
  def status_groups
    url = "#{@url}reference/status-groups"
    make_request(url)
  end

  # Get statuses
  # http://www.retailcrm.ru/docs/Разработчики/СправочникМетодовAPIV3
  #
  def statuses
    url = "#{@url}reference/statuses"
    make_request(url)
  end

  ##
  # ===  Edit status
  # http://www.retailcrm.ru/docs/Разработчики/СправочникМетодовAPIV3
  #
  def statuses_edit(status)
    code = status[:code]
    url = "#{@url}reference/statuses/#{code}/edit"
    make_request(url, 'post')
  end

  ##
  # ===  Get stores
  # http://www.retailcrm.ru/docs/Разработчики/СправочникМетодовAPIV3
  #
  def stores
    url = "#{@url}reference/stores"
    make_request(url)
  end

  ##
  # ===  Edit store
  # http://www.retailcrm.ru/docs/Разработчики/СправочникМетодовAPIV3
  #
  def stores_edit(store)
    code = store[:code]
    url = "#{@url}reference/stores/#{code}/edit"
    make_request(url, 'post')
  end


  ##
  # ===  Statistic update
  # http://www.retailcrm.ru/docs/Разработчики/СправочникМетодовAPIV3
  #
  def statistic_update
    url = "#{@url}statistic/update"
    make_request(url)
  end

  protected

  def make_request(url, method='get')
    raise ArgumentError, 'url must be not empty' unless !url.empty?
    uri = URI.parse(url)
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true

    if method == 'post'
      request = Net::HTTP::Post.new(uri)
      request.set_form_data(@params)
    elsif method == 'get'
      request = Net::HTTP::Get.new(uri.path)
      request.set_form_data(@params)

      if @filter.nil?
        data = "#{request.body}"
      else
        data = "#{request.body}&#{@filter}"
      end

      if @ids.nil?
        data = "#{request.body}"
      else
        data = "#{request.body}&#{@ids}"
      end

      request = Net::HTTP::Get.new("#{uri.path}?#{data}")
    end
    response = https.request(request)
    Retailcrm::Response.new(response.code, response.body)
  end
end

class Retailcrm::Response
    attr_reader :status, :response

    def initialize(status, body)
        @status = status
        @response = body.empty? ? [] : JSON.parse(body)
    end

    def is_successfull?
        @status.to_i < 400
    end
end
