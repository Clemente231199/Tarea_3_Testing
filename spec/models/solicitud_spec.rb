require 'rails_helper'

RSpec.describe Solicitud, type: :model do
  let(:user) { User.create(name: "Juan Pérez", email: "juan.perez@example.com", password: "Password123!") }
  let(:product) { Product.create(nombre: "Producto 1", precio: 2000, stock: 5, user_id: user.id, categories: 'Cancha') }

  subject do
    described_class.new(
      stock: 3,
      status: "Pendiente",
      user: user,
      product: product
    )
  end

  context 'validaciones' do
    it 'es válido con atributos válidos' do
      expect(subject).to be_valid
    end

    it 'no es válido sin stock' do
      subject.stock = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:stock]).to include("no puede estar en blanco")
    end

    it 'no es válido si el stock no es un número entero mayor que 0' do
      subject.stock = 0
      expect(subject).to_not be_valid
      expect(subject.errors[:stock]).to include("debe ser mayor que 0")
    end

    it 'no es válido sin estado' do
      subject.status = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:status]).to include("no puede estar en blanco")
    end

    it 'no es válido sin usuario' do
      subject.user = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:user]).to include("debe existir")
    end

    it 'no es válido sin producto' do
      subject.product = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:product]).to include("debe existir")
    end
  end
end
