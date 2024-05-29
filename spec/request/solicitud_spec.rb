require 'rails_helper'
require 'faker'

RSpec.describe Solicitud, type: :request do
  before do
    @user = User.create(
      name: "John Doe 1",
      email: "john.doe1@example.com",
      password: "Password123!",
      password_confirmation: "Password123!"
    )

    @product = Product.create(
      nombre: 'John1',
      precio: 4000, stock: 10,
      user_id: @user.id,
      categories: 'Cancha')

      @solicitud = Solicitud.create(
        stock: 5,
        status: "pending",
        user_id: @user.id,
        product_id: @product.id
        )

      @solicitud_count=Solicitud.count
    sign_in @user
  end

  describe 'insertar' do
    context 'cuando hay suficiente stock' do
      it 'crea una nueva solicitud y redirige con un mensaje de éxito' do
        post solicitud_insertar_path, params: { solicitud: { stock: 3 }, product_id: @product.id }
        expect(Solicitud.count).to eq(@solicitud_count+1)
        expect(flash[:notice]).to eq('Solicitud de compra creada correctamente!')
        expect(response).to have_http_status(:redirect)
        end
      end
    end

  describe 'get index' do
    it 'asigna las solicitudes y productos del usuario actual' do
      get solicitud_index_path
      expect(response).to have_http_status(:ok)
      expect(assigns(:solicitudes)).to eq([@solicitud])
      expect(assigns(:productos)).to eq([@product])
    end


    it 'retorna si no está logueado' do
      sign_out @user
      get solicitud_index_path
      expect(response).to have_http_status(:redirect)
    end

    it 'renderiza la plantilla index' do
      get solicitud_index_path
      expect(response).to render_template(:index)
    end




    context 'cuando no hay suficiente stock' do
      it 'no crea una solicitud y redirige con un mensaje de error' do
        post solicitud_insertar_path, params: { solicitud: { stock: 15 }, product_id: @product.id }
        expect(flash[:error]).to eq('No hay suficiente stock para realizar la solicitud!')
        expect(response).to have_http_status(:redirect)
      end
    end
  end
end


# """before do
#     @user = FactoryBot.create(:user)
#     @product = FactoryBot.create(:product, user: @user, stock: 10)
#     @solicitud = FactoryBot.create(:solicitud, user: @user, product: @product, stock: 5)
#     sign_in @user
#   end"""
