# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MessageController, type: :controller do
  before do
    @user = User.create!(name: 'John1', password: 'Nonono123!', email: 'asdf@gmail.com',
                         role: 'admin')
    sign_in @user
    @product = Product.create!(nombre: 'John1', precio: 4000, stock: 1, user_id: @user.id, categories: 'Cancha')
  end

  describe 'POST #insertar' do
    context 'con parámetros válidos' do
      it 'crea un nuevo mensaje y redirige a la página del producto' do
        expect do
          post :insertar, params: {
            product_id: @product.id,
            message: { body: 'Test message' }
          }
        end.to change(Message, :count).by(1)

        expect(flash[:notice]).to eq('Pregunta creada correctamente!')
        expect(response).to redirect_to("/products/leer/#{@product.id}")
      end
    end

    context 'con parámetros inválidos' do
      it 'no crea un nuevo mensaje y redirige a la página de lectura del producto' do
        expect do
          post :insertar, params: {
            product_id: @product.id,
            message: { body: '' } # cuerpo del mensaje vacío
          }
        end.not_to change(Message, :count)

        expect(flash[:error]).to eq('Hubo un error al guardar la pregunta. ¡Completa todos los campos solicitados!')
        expect(response).to redirect_to("/products/leer/#{@product.id}")
      end
    end

    describe 'POST #elminar' do
      context 'existe usuario' do
        before do
          @message = Message.create!(body: 'Test Message', product: @product, user: @user) # Adjust attributes as necessary
          # Debugging output to ensure the message is created
          puts "Message creation failed: #{@message.errors.full_messages}" unless @message.persisted?
        end

        it 'elimina el mensaje y redirige a la página de lectura del producto' do
          expect do
            delete :eliminar, params: { message_id: @message.id, product_id: @product.id }
          end.to change(Message, :count).by(-1)

          expect(response).to redirect_to("/products/leer/#{@product.id}")
        end
      end
    end
  end
end
