require 'sinatra'
require 'json'


$inventory = []      
$suppliers = []      
$orders = []          


get '/' do
  "Welcome to the InventoryMaster API!"
end


get '/inventory' do
  content_type :json
  $inventory.to_json
end

post '/inventory' do
  content_type :json
  data = JSON.parse(request.body.read)
  product = {
    id: ($inventory.empty? ? 1 : $inventory.last[:id] + 1),
    name: data['name'],
    stock: data['stock'],
    price: data['price']
  }
  $inventory << product
  product.to_json
end

put '/inventory/:id' do
  content_type :json
  id = params[:id].to_i
  data = JSON.parse(request.body.read)
  product = $inventory.find { |p| p[:id] == id }
  if product
    product[:stock] = data['stock'] if data.key?('stock')
    product.to_json
  else
    halt 404, { error: 'Product not found' }.to_json
  end
end

delete '/inventory/:id' do
  content_type :json
  id = params[:id].to_i
  product = $inventory.find { |p| p[:id] == id }
  if product
    $inventory.delete(product)
    { message: 'Product deleted' }.to_json
  else
    halt 404, { error: 'Product not found' }.to_json
  end
end


get '/suppliers' do
  content_type :json
  $suppliers.to_json
end

post '/suppliers' do
  content_type :json
  data = JSON.parse(request.body.read)
  supplier = {
    id: ($suppliers.empty? ? 1 : $suppliers.last[:id] + 1),
    name: data['name'],
    contact: data['contact']
  }
  $suppliers << supplier
  supplier.to_json
end


get '/orders' do
  content_type :json
  $orders.to_json
end

post '/orders' do
  content_type :json
  data = JSON.parse(request.body.read)

 
  product = $inventory.find { |p| p[:id] == data['product_id'] }
  supplier = $suppliers.find { |s| s[:id] == data['supplier_id'] }

  if product && supplier
    
    order = {
      id: ($orders.empty? ? 1 : $orders.last[:id] + 1),
      product_name: product[:name],
      quantity: data['quantity'],
      supplier_name: supplier[:name]
    }
    $orders << order

    
    product[:stock] -= data['quantity'].to_i

    order.to_json
  else
    halt 404, { error: 'Product or Supplier not found' }.to_json
  end
end

delete '/orders/:id' do
  content_type :json
  id = params[:id].to_i
  order = $orders.find { |o| o[:id] == id }
  if order
    $orders.delete(order)
    { message: 'Order deleted' }.to_json
  else
    halt 404, { error: 'Order not found' }.to_json
  end
end

