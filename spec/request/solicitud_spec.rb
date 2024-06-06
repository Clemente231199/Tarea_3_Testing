# frozen_string_literal: true

require 'rails_helper'
require 'faker'

RSpec.describe Solicitud, type: :request do
  before do
    @user = User.create(
      name: 'John Doe 1',
      email: 'john.doe1@example.com',
      password: 'Password123!',
      password_confirmation: 'Password123!'
    )

    @product = Product.create(
      nombre: 'John1',
      precio: 4000, stock: 10,
      user_id: @user.id,
      categories: 'Cancha'
    )

    @solicitud = Solicitud.create(
      stock: 5,
      status: 'pending',
      user_id: @user.id,
      product_id: @product.id
    )

    @solicitud_count = Solicitud.count
    sign_in @user
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

  describe 'insertar' do
    context 'cuando hay suficiente stock' do
      it 'crea una nueva solicitud y redirige con un mensaje de éxito' do
        post solicitud_insertar_path,
             params: { solicitud: { stock: 3, reservation_datetime: '2024-06-06T12:00:00' }, product_id: @product.id }
        expect(Solicitud.count).to eq(@solicitud_count + 1)
        expect(flash[:notice]).to eq('Solicitud de compra creada correctamente!')
        expect(response).to have_http_status(:redirect)
      end
    end
    context 'cuando falla insertar' do
      it 'crea una nueva solicitud y redirige con un mensaje de éxito' do
        allow_any_instance_of(Solicitud).to receive(:save).and_return(false)
        post solicitud_insertar_path,
             params: { solicitud: { stock: 3, reservation_datetime: '2024-06-06T12:00:00' }, product_id: @product.id }
        expect(flash[:error]).to eq('Hubo un error al guardar la solicitud!')
        expect(response).to have_http_status(:redirect)
      end
    end
  end
  describe 'Eliminar' do
    it 'happy' do
      delete "/solicitud/eliminar/#{@solicitud.id}"
      expect(flash[:notice]).to eq('Solicitud eliminada correctamente!')
      expect(response).to have_http_status(:redirect)
    end
    it 'falla' do
      allow_any_instance_of(Solicitud).to receive(:destroy).and_return(false)
      delete "/solicitud/eliminar/#{@solicitud.id}"
      expect(flash[:error]).to eq('Hubo un error al eliminar la solicitud!')
      expect(response).to have_http_status(:redirect)
    end
  end
  describe 'actualizar' do
    it 'happy' do
      patch "/solicitud/actualizar/#{@solicitud.id}"
      expect(flash[:notice]).to eq('Solicitud aprobada correctamente!')
      expect(response).to have_http_status(:redirect)
    end
    it 'falla' do
      allow_any_instance_of(Solicitud).to receive(:update).and_return(false)
      patch "/solicitud/actualizar/#{@solicitud.id}"
      expect(flash[:error]).to eq('Hubo un error al aprobar la solicitud!')
      expect(response).to have_http_status(:redirect)
    end
  end
end

# """before do
#     @user = FactoryBot.create(:user)
#     @product = FactoryBot.create(:product, user: @user, stock: 10)
#     @solicitud = FactoryBot.create(:solicitud, user: @user, product: @product, stock: 5)
#     sign_in @user
#   end"""
