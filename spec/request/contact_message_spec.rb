require 'rails_helper'

RSpec.describe ContactMessageController, type: :controller do
  before do
    @user = User.create(
      name: "Admin User",
      email: "admin@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      role: 'admin'
    )

    sign_in @user
  end

  let(:valid_attributes) do
    {
      name: "Test User",
      mail: "test@example.com",
      phone: "+56999999999",
      title: "Test Title",
      body: "Test Body"
    }
  end

  let(:invalid_attributes) do
    {
      name: "",
      mail: "",
      phone: "",
      title: "",
      body: ""
    }
  end

  describe 'POST #crear' do
    context 'con atributos válidos' do
      it 'crea un nuevo mensaje de contacto y redirige con un mensaje de éxito' do
        expect {
          post :crear, params: { contact: valid_attributes }
        }.to change(ContactMessage, :count).by(1)
        expect(flash[:notice]).to eq('Mensaje de contacto enviado correctamente')
        expect(response).to redirect_to('/contacto')
      end
    end

    context 'con atributos inválidos' do
      it 'no crea un nuevo mensaje de contacto y redirige con un mensaje de error' do
        expect {
          post :crear, params: { contact: invalid_attributes }
        }.not_to change(ContactMessage, :count)
        expect(flash[:alert]).to include('Error al enviar el mensaje de contacto')
        expect(response).to redirect_to('/contacto')
      end
    end
  end

  describe 'GET #mostrar' do
    it 'asigna todos los mensajes de contacto a @contact_messages en orden descendente' do
      contact_message = ContactMessage.create! valid_attributes
      get :mostrar
      expect(assigns(:contact_messages)).to eq([contact_message])
      expect(response).to render_template('contacto')
    end
  end

  describe 'DELETE #eliminar' do
    context 'cuando es admin' do
      it 'elimina el mensaje de contacto y redirige con un mensaje de éxito' do
        contact_message = ContactMessage.create! valid_attributes
        expect {
          delete :eliminar, params: { id: contact_message.id }
        }.to change(ContactMessage, :count).by(-1)
        expect(flash[:notice]).to eq('Mensaje de contacto eliminado correctamente')
        expect(response).to redirect_to('/contacto')
      end

      it 'muestra un mensaje de error si el mensaje no se puede eliminar' do
        contact_message = ContactMessage.create! valid_attributes
        allow_any_instance_of(ContactMessage).to receive(:destroy).and_return(false)
        delete :eliminar, params: { id: contact_message.id }
        expect(flash[:alert]).to eq('Error al eliminar el mensaje de contacto')
        expect(response).to redirect_to('/contacto')
      end
    end

    context 'cuando no es admin' do
      before do
        @user.update(role: 'user')
      end

      it 'no permite eliminar el mensaje y redirige con un mensaje de error' do
        contact_message = ContactMessage.create! valid_attributes
        delete :eliminar, params: { id: contact_message.id }
        expect(ContactMessage.count).to eq(1)
        expect(flash[:alert]).to eq('Debes ser un administrador para eliminar un mensaje de contacto.')
        expect(response).to redirect_to('/contacto')
      end
    end
  end

  describe 'DELETE #limpiar' do
    context 'cuando es admin' do
      it 'elimina todos los mensajes de contacto y redirige con un mensaje de éxito' do
        ContactMessage.create! valid_attributes
        expect {
          delete :limpiar
        }.to change(ContactMessage, :count).by(-1)
        expect(flash[:notice]).to eq('Mensajes de contacto eliminados correctamente')
        expect(response).to redirect_to('/contacto')
      end

      it 'muestra un mensaje de error si no se pueden eliminar los mensajes' do
        ContactMessage.create! valid_attributes
        allow(ContactMessage).to receive(:destroy_all).and_return(false)
        delete :limpiar
        expect(flash[:alert]).to eq('Error al eliminar los mensajes de contacto')
        expect(response).to redirect_to('/contacto')
      end
    end

    context 'cuando no es admin' do
      before do
        @user.update(role: 'user')
      end

      it 'no permite eliminar los mensajes y redirige con un mensaje de error' do
        ContactMessage.create! valid_attributes
        delete :limpiar
        expect(ContactMessage.count).to eq(1)
        expect(flash[:alert]).to eq('Debes ser un administrador para eliminar los mensajes de contacto.')
        expect(response).to redirect_to('/contacto')
      end
    end
  end
end
