require 'rails_helper'

RSpec.describe 'Productos', type: :request do
  before do
    @usuario = User.create!(name: 'Juan1', password: 'NoNo1234!', email: 'juan.perez@example.com',
                            role: 'admin')
    sign_in @usuario
    @producto = Product.create!(nombre: 'John1', precio: 4000, stock: 1, user_id: @usuario.id, categories: 'Cancha')

  end

  describe 'GET /products/index' do
    it 'returns http success' do
      get '/products/index'
      expect(response).to have_http_status(:success)
    end

    context 'when category and search parameters are present' do
      it 'filters products by category and search term' do
        get '/products/index', params: { category: 'Cancha', search: 'John' }
        expect(assigns(:products)).to include(@producto)
      end
    end

    context 'when only category parameter is present' do
      it 'filters products by category' do
        get '/products/index', params: { category: 'Cancha' }
        expect(assigns(:products)).to include(@producto)
      end
    end

    context 'when only search parameter is present' do
      it 'filters products by search term' do
        get '/products/index', params: { search: 'John1' }
        expect(assigns(:products)).to include(@producto)
      end
    end
  end

  describe 'GET /products/leer/:id' do
    it 'returns http success' do
      get "/products/leer/#{@producto.id}"
      expect(response).to have_http_status(:success)
    end
    it 'producto tiene review' do
      @review = Review.create!(user:@usuario,product:@producto ,tittle:"John1",description:"Lo pase muy bien",calification:"5")
      get "/products/leer/#{@producto.id}"
      expect(response).to have_http_status(:success)
    end
    it 'producto tiene horario' do
      @producto.update(horarios:"11;12;13")
      get "/products/leer/#{@producto.id}"
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /products/crear' do
    it 'returns http success' do
      get '/products/crear'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /products/insert_deseado/:product_id' do
    it 'adds a product to the user wishlist' do
      post "/products/insert_deseado/#{@producto.id}"
      expect(response).to redirect_to("/products/leer/#{@producto.id}")
      expect(flash[:notice]).to eq('Producto agregado a la lista de deseados')
      expect(@usuario.reload.deseados).to include(@producto.id.to_s)
    end
  end

  describe 'POST /products/insertar' do
    context 'when user is an admin' do
      it 'creates a product' do
        post '/products/insertar', params: { product: { nombre: 'Nuevo Producto', precio: 50, stock: 5, categories: 'Suplementos' } }
        expect(flash[:notice]).to eq('Producto creado Correctamente !')
        expect(response).to redirect_to('/products/index')
      end
    end

    context 'when user is not an admin' do
      before do
        @usuario.update(role: 'regular')
      end

      it 'redirects to index with an alert' do
        post '/products/insertar', params: { product: { nombre: 'Nuevo Producto', precio: 50, stock: 5, categories: 'Nueva Categoría' } }
        expect(flash[:alert]).to eq('Debes ser un administrador para crear un producto.')
        expect(response).to redirect_to('/products/index')
      end
    end
  end

  describe 'GET /products/actualizar/:id' do
    it 'returns http success' do
      get "/products/actualizar/#{@producto.id}"
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /products/actualizar/:id' do
    context 'when user is an admin' do
      it 'updates a product' do
        patch "/products/actualizar/#{@producto.id}", params: { product: { nombre: 'Producto Modificado' } }
        expect(response).to redirect_to('/products/index')
      end
    end

    context 'when user is not an admin' do
      before do
        @usuario.update(role: 'regular')
      end

      it 'redirects to index with an alert' do
        patch "/products/actualizar/#{@producto.id}", params: { product: { nombre: 'Producto Modificado' } }
        expect(flash[:alert]).to eq('Debes ser un administrador para modificar un producto.')
        expect(response).to redirect_to('/products/index')
      end
    end
  end

  describe 'DELETE /products/eliminar/:id' do
    context 'when user is an admin' do
      it 'deletes a product' do
        delete "/products/eliminar/#{@producto.id}"
        expect(response).to redirect_to('/products/index')
      end
    end

    context 'when user is not an admin' do
      before do
        @usuario.update(role: 'regular')
      end

      it 'redirects to index with an alert' do
        delete "/products/eliminar/#{@producto.id}"
        expect(flash[:alert]).to eq('Debes ser un administrador para eliminar un producto.')
        expect(response).to redirect_to('/products/index')
      end
    end
  end
end
