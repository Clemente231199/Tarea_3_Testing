# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShoppingCartController, type: :controller do
  before do
    @user = User.create(
      name: 'John Doe 1',
      email: 'john.doe1@example.com',
      password: 'Password123!',
      password_confirmation: 'Password123!'
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
    @shopping_cart.products = {}
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
      it 'no muestra el carro de compras ' do
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

      it 'crea un nuevo carro de compras si no existe' do
        @shopping_cart.destroy
        get :details
        expect(assigns(:shopping_cart)).not_to be_nil
        expect(assigns(:shopping_cart).user_id).to eq(@user.id)
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
      it 'crea un nuevo carro de compras si no existe' do
        @shopping_cart.destroy
        post :insertar_producto, params: { product_id: @product.id, add: { amount: 1 } }
        expect(assigns(:shopping_cart)).not_to be_nil
        expect(assigns(:shopping_cart).user_id).to eq(@user.id)
      end
      it 'falla crear carro' do
        @shopping_cart.destroy
        allow_any_instance_of(ShoppingCart).to receive(:save).and_return(false)
        expect do
          post :insertar_producto, params: { product_id: @product.id, add: { amount: 1 } }
        end.to raise_error(NoMethodError)
        expect(flash[:alert]).to eq('Hubo un error al crear el carro. Contacte un administrador.')
        expect(response).to redirect_to(root_path)
      end

      it 'agrega un producto al carro de compras y redirige a detalles si buy_now es true' do
        post :comprar_ahora, params: { product_id: @product.id, add: { amount: 1 } }
        expect(@shopping_cart.reload.products).to include(@product.id.to_s => 1)
        expect(response).to redirect_to('/carro/detalle')
      end

      it 'agrega un producto al carro de compras' do
        post :insertar_producto, params: { product_id: @product.id, add: { amount: 1 } }
        expect(@shopping_cart.reload.products).to include(@product.id.to_s => 1)
        expect(flash[:notice]).to eq('Producto agregado al carro de compras')
        expect(response).to redirect_to(root_path)
      end

      it 'agrega un producto ya existente al carro de compras' do
        post :insertar_producto, params: { product_id: @product.id, add: { amount: 1 } }
        post :insertar_producto, params: { product_id: @product.id, add: { amount: 1 } }
        expect(@shopping_cart.reload.products).to include(@product.id.to_s => 2)
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

      it 'redirige al carro si falla el update' do
        allow_any_instance_of(ShoppingCart).to receive(:update).and_return(false)
        post :insertar_producto, params: { product_id: @product2.id, add: { amount: 1 } }
        expect(flash[:alert]).to include('Hubo un error al agregar el producto al carro de compras')
        expect(response).to have_http_status(:unprocessable_entity)
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

    it 'ocurre error al eliminar un producto del carro de compras' do
      @shopping_cart.products = { @product.id.to_s => 1 }
      @shopping_cart.save
      allow_any_instance_of(ShoppingCart).to receive(:update).and_return(false)
      delete :eliminar_producto, params: { product_id: @product.id }
      expect(@shopping_cart.reload.products).to include(@product.id.to_s)
      expect(flash[:alert]).to eq('Hubo un error al eliminar el producto del carro de compras')
      expect(response).to redirect_to('/carro')
    end

    it 'redirige al carro si el producto no existe en el carro' do
      delete :eliminar_producto, params: { product_id: @product.id }
      expect(flash[:alert]).to eq('El producto no existe en el carro de compras')
      expect(response).to redirect_to('/carro')
    end
  end

  describe 'POST #realizar_compra' do
    context 'usuario autenticado' do
      it 'redirige al carro si no hay carro de compras' do
        @shopping_cart.destroy
        post :realizar_compra
        expect(flash[:alert]).to eq('No se encontró tu carro de compras. Contacte un administrador.')
        expect(response).to redirect_to('/carro')
      end

      it 'redirige al carro si el carro está vacío' do
        post :realizar_compra
        expect(flash[:alert]).to eq('No tienes productos en el carro de compras')
        expect(response).to redirect_to('/carro')
      end

      it 'falla crear solicitud' do
        @shopping_cart.products = { @product.id.to_s => 1 }
        @shopping_cart.save
        allow_any_instance_of(Product).to receive(:update).and_return(false)
        allow_any_instance_of(Solicitud).to receive(:save).and_return(false)
        post :realizar_compra
        expect(flash[:alert]).to eq('Hubo un error al realizar la compra. Contacte un administrador.')
        expect(response).to redirect_to('/carro')
      end

      it 'realiza la compra y limpia el carro' do
        @shopping_cart.products = { @product.id.to_s => 1 }
        @shopping_cart.save
        post :realizar_compra
        expect(flash[:notice]).to eq('Compra realizada exitosamente')
        expect(@shopping_cart.reload.products).to be_empty
        expect(response).to redirect_to('/solicitud/index')
      end

      it 'redirige al carro si no hay suficiente stock' do
        @shopping_cart.products = { @product.id.to_s => 11 }
        @shopping_cart.save
        post :realizar_compra
        expect(flash[:alert]).to include("Compra cancelada: El producto '#{@product.nombre}' no tiene suficiente stock")
        expect(response).to redirect_to('/carro')
      end

      it 'redirige al carro si hay un error al guardar la solicitud' do
        allow_any_instance_of(ShoppingCart).to receive(:update).and_return(false)
        @shopping_cart.products = { @product.id.to_s => 1 }
        @shopping_cart.save
        post :realizar_compra
        expect(flash[:alert]).to eq('Hubo un error al actualizar el carro. Contacte un administrador.')
        expect(response).to redirect_to('/carro')
      end
    end
  end

  describe 'POST #limpiar' do
    context 'usuario autenticado' do
      it 'limpia el carro de compras' do
        @shopping_cart.products = { @product.id.to_s => 1 }
        @shopping_cart.save
        post :limpiar
        expect(@shopping_cart.reload.products).to be_empty
        expect(flash[:notice]).to eq('Carro de compras limpiado exitosamente')
        expect(response).to redirect_to('/carro')
      end

      it 'muestra un error si hay un problema al limpiar el carro' do
        allow_any_instance_of(ShoppingCart).to receive(:update).and_return(false)
        post :limpiar
        expect(flash[:alert]).to eq('Hubo un error al limpiar el carro de compras. Contacte un administrador.')
        expect(response).to redirect_to('/carro')
      end
    end
  end
end
