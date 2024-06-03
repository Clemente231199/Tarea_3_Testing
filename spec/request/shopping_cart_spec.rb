require 'rails_helper'

RSpec.describe ShoppingCartController, type: :controller do
  before do
    @user = User.create(
      name: "John Doe 1",
      email: "john.doe1@example.com",
      password: "Password123!",
      password_confirmation: "Password123!"
    )
    sign_in @user

    @product = Product.create(
      nombre: 'John1',
      precio: 4000,
      stock: 10,
      user_id: @user.id,
      categories: 'Cancha'
    )
    @product2 = Product.create(
      nombre: 'John2',
      precio: 6000,
      stock: 150,
      user_id: @user.id,
      categories: 'Cancha'
    )
    @shopping_cart = ShoppingCart.create(user_id: @user.id)
    @shopping_cart.products ={}
    @shopping_cart.save
  end

  describe 'GET #show' do
    context 'usuario autenticado' do
      it 'muestra el carro de compras si existe' do
        @shopping_cart.products = {
          @product.id.to_s => 2
        }
        @shopping_cart.save
        get :show
        expect(assigns(:shopping_cart)).to eq(@shopping_cart)
        expect(response).to render_template(:show)
      end

      it 'crea un nuevo carro de compras si no existe' do
        @shopping_cart.destroy
        get :show
        expect(assigns(:shopping_cart)).not_to be_nil
        expect(assigns(:shopping_cart).user_id).to eq(@user.id)
      end
    end

    context 'usuario no autenticado' do
      it 'no muestra el carro de compras y redirige a /carro' do
        sign_out @user
        get :show
        expect(assigns(:shopping_cart)).to be_nil
      end
    end
  end

  describe 'GET #details' do
    context 'usuario autenticado' do
      it 'muestra los detalles del carro de compras si tiene productos' do
        @shopping_cart.products = {
          @product.id.to_s => 2
        }
        @shopping_cart.save
        get :details
        expect(assigns(:shopping_cart)).to eq(@shopping_cart)
        expect(assigns(:total_pago)).to eq(@product.precio.to_i * 2 + @shopping_cart.costo_envio.to_i)
        expect(response).to render_template(:details)
      end

      it 'redirige al carro si no tiene productos' do
        get :details
        expect(flash[:alert]).to eq('No tienes productos que comprar.')
        expect(response).to redirect_to('/carro')
      end
    end

    context 'usuario no autenticado' do
      it 'redirige a root' do
        sign_out @user
        get :details
        expect(flash[:alert]).to eq('Debes iniciar sesión para comprar.')
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'POST #insertar_producto' do
    context 'usuario autenticado' do
      it 'agrega un producto al carro de compras' do
        post :insertar_producto, params: { product_id: @product.id, add: { amount: 1 } }
        expect(@shopping_cart.reload.products).to include(@product.id.to_s => 1)
        expect(flash[:notice]).to eq('Producto agregado al carro de compras')
        expect(response).to redirect_to(root_path)
      end

      it 'redirige al carro si se excede el límite de productos' do
        @shopping_cart.products = {}
        8.times { |i| @shopping_cart.products[i.to_s] = 1 }
        @shopping_cart.save
        post :insertar_producto, params: { product_id: @product.id, add: { amount: 1 } }
        expect(flash[:alert]).to include('Has alcanzado el máximo de productos en el carro de compras')
        expect(response).to redirect_to(root_path)
      end

      it 'redirige al carro si no hay suficiente stock' do
        @product.update(stock: 0)
        post :insertar_producto, params: { product_id: @product.id, add: { amount: 1 } }
        expect(flash[:alert]).to include("El producto '#{@product.nombre}' no tiene suficiente stock")
        expect(response).to redirect_to(root_path)
      end

      it 'redirige al carro si se excede la cantidad máxima por compra' do
        post :insertar_producto, params: { product_id: @product2.id, add: { amount: 101 } }
        expect(flash[:alert]).to include("El producto '#{@product2.nombre}' tiene un máximo de 100")
        expect(response).to redirect_to(root_path)
      end
    end

    context 'usuario no autenticado' do
      it 'redirige al inicio' do
        sign_out @user
        post :insertar_producto, params: { product_id: @product.id, add: { amount: 1 } }
        expect(flash[:alert]).to eq('Debes iniciar sesión para agregar productos al carro de compras.')
        expect(response).to redirect_to('/carro')
      end
    end
  end

  describe 'DELETE #eliminar_producto' do
    it 'elimina un producto del carro de compras' do
      @shopping_cart.products = { @product.id.to_s => 1 }
      @shopping_cart.save
      delete :eliminar_producto, params: { product_id: @product.id }
      expect(@shopping_cart.reload.products).not_to include(@product.id.to_s)
      expect(flash[:notice]).to eq('Producto eliminado del carro de compras')
      expect(response).to redirect_to('/carro')
    end

    it 'redirige al carro si el producto no existe en el carro' do
      delete :eliminar_producto, params: { product_id: @product.id }
      expect(flash[:alert]).to eq('El producto no existe en el carro de compras')
      expect(response).to redirect_to('/carro')
    end
  end
end
