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
        expect {
          post :insertar, params: {
            product_id: @product.id,
            message: { body: "Test message" }
          }
        }.to change(Message, :count).by(1)
        
        expect(flash[:notice]).to eq('Pregunta creada correctamente!')
        expect(response).to redirect_to("/products/leer/#{@product.id}")
      end
    end

    context 'con parámetros inválidos' do
      it 'no crea un nuevo mensaje y redirige a la página de lectura del producto' do
        expect {
          post :insertar, params: {
            product_id: @product.id,
            message: { body: "" } # cuerpo del mensaje vacío
          }
        }.not_to change(Message, :count)

        expect(flash[:error]).to eq('Hubo un error al guardar la pregunta. ¡Completa todos los campos solicitados!')
        expect(response).to redirect_to("/products/leer/#{@product.id}")
      end
    end
  end
end
