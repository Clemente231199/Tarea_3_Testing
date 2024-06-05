require 'rails_helper'

RSpec.describe 'Products', type: :request do
  before do
    @user = User.create!(name: 'John1', password: 'Nonono123!', email: 'asdf@gmail.com',
                         role: 'admin')
    @user_non_admin = User.create!(name: 'Clemente', password: 'Nonono123!', email: 'asdf2@gmail.com',
                         role: '')
    sign_in @user
    @product = Product.create!(nombre: 'John1', precio: 4000, stock: 1, user_id: @user.id, categories: 'Cancha')
  end

  #####INDEX######
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

  ######LEER######
  describe 'GET /products/leer/:id' do
    it 'returns http success' do
      get "/products/leer/#{@product.id}"
      expect(response).to have_http_status(:success)
    end

    it 'assigns the requested product to @product' do
      get "/products/leer/#{@product.id}"
      expect(assigns(:product)).to eq(@product)
      expect(response).to render_template('leer')
    end
  end

  ######CREAR######
  describe 'GET #crear' do
    it 'assigns a new product to @product' do
      sign_in @user
      get '/products/crear'
      expect(assigns(:product)).to be_a_new(Product)
      expect(response).to render_template('crear')
    end
  end

######  INSERT DESEADOS ######

  describe 'POST /products/insert_deseado/:product_id' do
    it 'adds the product_id to deseados' do
      post "/products/insert_deseado/#{@product.id}"
      expect(flash[:notice]).to eq('Producto agregado a la lista de deseados')
      expect(response).to redirect_to("/products/leer/#{@product.id}")
      @user.reload
      expect(@user.deseados).to include(@product.id.to_s)
    end

    context 'when there is an error saving the user' do
      before do
        allow_any_instance_of(User).to receive(:save).and_return(false)
        allow_any_instance_of(User).to receive_message_chain(:errors, :full_messages).and_return(['Some error'])
      end
      it 'sets a flash error' do
        post "/products/insert_deseado/#{@product.id}"
        expect(flash[:error]).to eq('Hubo un error al guardar los cambios: Some error')
        expect(response).to redirect_to("/products/leer/#{@product.id}")
      end
    end
  end
#####  INSERT  ######
  describe 'POST #insertar' do

    it 'creates a new product en caso admin' do
      expect{
        post '/products/insertar', params: {product:{nombre:"Tasa", precio:5 ,stock:10, categories:"Equipamiento", horarios:"12" }}
        }.to change(Product, :count).by(1)
      expect(flash[:notice]).to eq('Producto creado Correctamente !')
      expect(response).to redirect_to('/products/index')
    end
  end
######  Actualizar  ######
  describe 'GET /actualizar' do
    it 'retrieves the product from the database' do
      get "/products/actualizar/#{@product.id}"
      expect(response).to have_http_status(:success)
      expect(assigns(:product)).to eq(@product)
    end
  end
#####  ACTUALIZAR_PRODUCTO ######
  describe 'POST #actualizar' do
    it 'happy path' do
      patch "/products/actualizar/#{@product.id}", params: { product: { precio: 200 } }

      expect(@product.reload.precio).to eq("200")
      expect(response).to redirect_to('/products/index')
    end

    it 'bad data' do
      patch "/products/actualizar/#{@product.id}", params: { product: { precio: nil } }
      expect(flash[:error]).to start_with('Hubo un error al guardar el producto')
      expect(response).to redirect_to("/products/actualizar/#{@product.id}")
    end

    it 'No admin' do
      sign_in @user_non_admin
      patch "/products/actualizar/#{@product.id}", params: { product: { precio: 200 } }
      expect(flash[:alert]).to eq("No estás autorizado para acceder a esta página")
    end
  end
######  ELIMINAR  ######
  describe 'DELETE #eliminar' do
    it 'deletes the product' do
      sign_in @user
      delete "/products/eliminar/#{@product.id}"
      expect(Product.exists?(@product.id)).to be_falsey
      expect(response).to redirect_to('/products/index')
    end
  end

  context 'when user is not an admin' do
    before do
      sign_in @user_non_admin
    end
    it 'sets a flash alert and redirects to products#index' do
      delete "/products/eliminar/#{@product.id}"
      expect(flash[:alert]).to eq("No estás autorizado para acceder a esta página")
    end

    it 'does not delete the product' do
      expect { delete "/products/eliminar/#{@product.id}" }.not_to change(Product, :count)
    end
  end

end
