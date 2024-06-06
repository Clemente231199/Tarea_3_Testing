require 'rails_helper'

RSpec.describe ShoppingCart, type: :model do
  let(:user) { User.create(name: "Ana Lopez", email: "ana.lopez@example.com", password: "Password123!") }
  let(:product1) { Product.create!(nombre: "Producto 1", precio: 2000, stock: 5, user_id: user.id, categories: 'Cancha') }
  let(:product2) { Product.create!(nombre: "Producto 2", precio: 3000, stock: 3, user_id: user.id, categories: 'Cancha') }

  subject do
    described_class.new(
      user: user,
      products: {
        product1.id => 2,
        product2.id => 1
      }
    )
  end

  context 'validaciones' do
    it 'es válido con atributos válidos' do
      expect(subject).to be_valid
    end

    it 'no es válido sin usuario' do
      subject.user = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:user]).to include("debe existir")
    end

    it 'es válido con productos vacíos' do
      subject.products = {}
      expect(subject).to be_valid
    end
  end

  context 'métodos' do
    describe '#precio_total' do
      it 'calcula el precio total de los productos en el carrito' do
        expect(subject.precio_total).to eq(7000)
      end

      it 'retorna 0 si no hay productos en el carrito' do
        subject.products = {}
        expect(subject.precio_total).to eq(0)
      end
    end

    describe '#costo_envio' do
      it 'calcula el costo de envío de los productos en el carrito' do
        expect(subject.costo_envio).to eq(1350)
      end

      it 'calcula el costo de envío cuando no hay productos en el carrito' do
        subject.products = {}
        expect(subject.costo_envio).to eq(1000)
      end
    end
  end
end
