# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Message, type: :model do
  let(:user) { User.create(name: 'Juan Perez', email: 'juan.perez@example.com', password: 'Password123!') }
  let(:product) { Product.create(nombre: 'Producto de Prueba', precio: 1000, stock: 10, user_id: user.id) }

  subject do
    described_class.new(
      body: 'Este es un mensaje de prueba.',
      user:,
      product:
    )
  end

  context 'validaciones' do
    it 'es válido con atributos válidos' do
      expect(subject).to be_valid
    end

    it 'no es válido sin un cuerpo' do
      subject.body = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:body]).to include('no puede estar en blanco')
    end

    it 'no es válido sin un user_id' do
      subject.user = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:user]).to include('debe existir')
    end

    it 'no es válido sin un product_id' do
      subject.product = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:product]).to include('debe existir')
    end
  end
end
