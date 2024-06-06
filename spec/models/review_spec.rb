# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Review, type: :model do
  let(:user) { User.create(name: 'Ana Lopez', email: 'ana.lopez@example.com', password: 'Password123!') }
  let(:product) { Product.create(nombre: 'Producto 1', precio: 2000, stock: 5, user:) }

  subject do
    described_class.new(
      tittle: 'Gran producto',
      description: 'Me ha encantado este producto, muy útil y de buena calidad.',
      calification: 4,
      user:,
      product:
    )
  end

  context 'validaciones' do
    it 'es válido con atributos válidos' do
      expect(subject).to be_valid
    end

    it 'no es válido sin título' do
      subject.tittle = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:tittle]).to include('no puede estar en blanco')
    end

    it 'no es válido con un título mayor a 100 caracteres' do
      subject.tittle = 'a' * 101
      expect(subject).to_not be_valid
      expect(subject.errors[:tittle]).to include('es demasiado largo (100 caracteres máximo)')
    end

    it 'no es válido sin descripción' do
      subject.description = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:description]).to include('no puede estar en blanco')
    end

    it 'no es válido con una descripción mayor a 500 caracteres' do
      subject.description = 'a' * 501
      expect(subject).to_not be_valid
      expect(subject.errors[:description]).to include('es demasiado largo (500 caracteres máximo)')
    end

    it 'no es válido sin calificación' do
      subject.calification = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:calification]).to include('no puede estar en blanco')
    end

    it 'no es válido con una calificación menor a 1' do
      subject.calification = 0
      expect(subject).to_not be_valid
      expect(subject.errors[:calification]).to include('debe ser mayor que o igual a 1')
    end

    it 'no es válido con una calificación mayor a 5' do
      subject.calification = 6
      expect(subject).to_not be_valid
      expect(subject.errors[:calification]).to include('debe ser menor que o igual a 5')
    end

    it 'no es válido sin usuario' do
      subject.user = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:user]).to include('debe existir')
    end

    it 'no es válido sin producto' do
      subject.product = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:product]).to include('debe existir')
    end
  end
end
