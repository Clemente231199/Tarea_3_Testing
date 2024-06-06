# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  subject do
    described_class.new(
      name: 'John Doe',
      email: 'john.doe@example.com',
      password: 'Password123!',
      password_confirmation: 'Password123!'
    )
  end

  context 'validaciones' do
    it 'es válido con atributos válidos' do
      expect(subject).to be_valid
    end

    it 'no es válido sin un nombre' do
      subject.name = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:name]).to include('no puede estar en blanco', 'es demasiado corto (2 caracteres mínimo)')
    end

    it 'no es válido con un nombre de menos de 2 caracteres' do
      subject.name = 'a'
      expect(subject).to_not be_valid
      expect(subject.errors[:name]).to include('es demasiado corto (2 caracteres mínimo)')
    end

    it 'no es válido con un nombre de más de 25 caracteres' do
      subject.name = 'a' * 26
      expect(subject).to_not be_valid
      expect(subject.errors[:name]).to include('es demasiado largo (25 caracteres máximo)')
    end

    it 'no es válido sin un correo electrónico' do
      subject.email = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:email]).to include('no puede estar en blanco')
    end

    it 'no es válido con un correo electrónico no único' do
      User.create(name: 'Jane Doe', email: 'john.doe@example.com', password: 'Password123!',
                  password_confirmation: 'Password123!')
      expect(subject).to_not be_valid
      expect(subject.errors[:email]).to include('ya está en uso')
    end

    it 'es válido con un correo electrónico único' do
      subject.email = 'unique.email@example.com'
      expect(subject).to be_valid
    end

    it 'es válido con una lista de deseados vacía' do
      subject.deseados = []
      expect(subject).to be_valid
    end

    it 'no es válido con un producto no existente en la lista de deseados' do
      subject.deseados = [999]
      expect(subject).to_not be_valid
      expect(subject.errors[:deseados]).to include('el articulo que se quiere ingresar a la lista de deseados no es valido')
    end

    it 'Error en contraseña muy simple "password123"' do
      subject.password = 'password123'
      subject.validate_password_strength
      expect(subject.errors[:password]).to include('no es válido incluir como minimo una mayuscula, minuscula y un simbolo')
    end

    it 'Error en contraseña muy simple "Password123/"' do
      subject.password = 'Password123/'
      subject.validate_password_strength
      expect(subject.errors[:password]).to be_empty
    end
  end

  context 'métodos de instancia' do
    it 'verifica si el usuario es administrador' do
      subject.role = 'admin'
      expect(subject.admin?).to be true

      subject.role = 'user'
      expect(subject.admin?).to be false
    end
  end
end
