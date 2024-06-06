require 'rails_helper'

RSpec.describe UsersController, type: :controller do

    before do
        @user = User.create!(name: 'John1', password: 'Nonono123!', email: 'asdf@gmail.com',
        role: 'admin')
        sign_in @user
        @product = Product.create!(nombre: 'John1', precio: 4000, stock: 1, user_id: @user.id, categories: 'Cancha')
        @user.deseados << @product.id
        @user.save
    end

  describe 'GET #show' do
    it 'asigna el usuario actual a @user' do
      get :show
      expect(assigns(:user)).to eq(@user)
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET #deseados' do
    it 'asigna los productos deseados del usuario actual a @deseados' do
      get :deseados
      expect(assigns(:deseados)).to include(@product.id.to_s)
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET #mensajes' do
    it 'asigna los mensajes del usuario actual a @user_messages y inicializa @shown_message_ids' do
        message = Message.create(body: "Test message", user_id: @user.id, product_id: @product.id)
        get :mensajes
        expect(assigns(:user_messages)).to include(message)
        expect(assigns(:shown_message_ids)).to eq([])
        expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST #actualizar_imagen' do
    context 'con una imagen válida' do
      it 'actualiza la imagen del usuario y redirige con un mensaje de éxito' do
        file = fixture_file_upload(Rails.root.join('spec', 'support', 'assets', 'test_image.jpg'), 'image/jpeg')
        post :actualizar_imagen, params: { image: file }
        expect(@user.reload.image).to be_attached
        expect(flash[:notice]).to eq('Imagen actualizada correctamente')
        expect(response).to redirect_to('/users/show')
      end
    end

    context 'con una imagen inválida' do
      it 'no actualiza la imagen y redirige con un mensaje de error' do
        file = fixture_file_upload(Rails.root.join('spec', 'support', 'assets', 'test_image.txt'), 'text/plain')
        post :actualizar_imagen, params: { image: file }
        expect(@user.reload.image).not_to be_attached
        expect(flash[:error]).to eq('Hubo un error al actualizar la imagen. Verifique que la imagen es de formato jpg, jpeg, png, gif o webp')
        expect(response).to redirect_to('/users/show')
      end
    end
  end

  describe 'DELETE #eliminar_deseado' do
    it 'elimina un producto de la lista de deseados del usuario y redirige con un mensaje de éxito' do
      delete :eliminar_deseado, params: { deseado_id: @product.id}
      expect(@user.reload.deseados).not_to include(@product.to_s)
      expect(flash[:notice]).to eq('Producto quitado de la lista de deseados')
      expect(response).to redirect_to('/users/deseados')
    end

    it 'redirige con un mensaje de error si no se puede eliminar el producto de la lista de deseados' do
      allow_any_instance_of(User).to receive(:save).and_return(false)
      delete :eliminar_deseado, params: { deseado_id: @product.id }
      expect(flash[:error]).to eq('Hubo un error al quitar el producto de la lista de deseados')
      expect(response).to redirect_to('/users/deseados')
    end
  end
end
