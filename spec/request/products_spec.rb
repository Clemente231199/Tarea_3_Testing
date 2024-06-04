require 'rails_helper'

RSpec.describe 'Products', type: :request do
  before do
    @user = User.create!(name: 'John1', password: 'Nonono123!', email: 'asdf@gmail.com',
                         role: 'admin')
    sign_in @user
    @product = Product.create!(nombre: 'John1', precio: 4000, stock: 1, user_id: @user.id, categories: 'Cancha')
  end

# routes
# get 'products/leer/:id', to: 'products#leer' # Ruta de la vista leer o ver los detalles de un registro
# get 'products/crear', to: 'products#crear' # Ruta de la vista para crear un registro
# post 'products/insertar', to: 'products#insertar' # Ruta que procesa la creación de un registro en la base de datos
# get 'products/actualizar/:id', to: 'products#actualizar' # Ruta de la vista para actualizar un registro
# patch 'products/actualizar/:id', to: 'products#actualizar_producto' # Ruta de la vista para actualizar un registro
# post 'products/editar/:id', to: 'products#editar' # Ruta que procesa la actualización de un registro en la database
# delete 'products/eliminar/:id', to: 'products#eliminar' # Ruta para eliminar un registro de la base de datos
# post 'products/insert_deseado/:product_id', to: 'products#insert_deseado' # Guardar producto en la lista de deseados


# get 'products/index', to: 'products#index' # Ruta de la vista principal de los registros
  describe 'GET /new' do
    it 'returns http success' do
      get '/products/index'
      expect(response).to have_http_status(:success)
    end
    it 'return http success without login' do
      sign_out @user
      get '/products/index'
      expect(response).to have_http_status(:success)
    end
  end
  describe 'GET /products/leer/:id' do
    it 'returns http success' do
      get "/products/leer/#{@product.id}"
      expect(response).to have_http_status(:success)
    end

    it 'assigns the requested product to @product' do
      get "/products/leer/#{@product.id}"
      expect(assigns(:product)).to eq(@product)
    end

    it 'renders the leer template' do
      get "/products/leer/#{@product.id}"
      expect(response).to render_template('leer')
    end
  end



end
