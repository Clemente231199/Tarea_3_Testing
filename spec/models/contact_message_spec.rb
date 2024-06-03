require 'rails_helper'

RSpec.describe ContactMessage, type: :model do
  subject do
    described_class.new(
      title: "Consulta",
      body: "Tengo una consulta sobre el producto.",
      name: "Juan Perez",
      mail: "juan.perez@example.com",
      phone: "+56912345678"
    )
  end

  context 'validaciones' do
    it 'es válido con atributos válidos' do
      expect(subject).to be_valid
    end

    it 'no es válido sin un título' do
      subject.title = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:title]).to include("no puede estar en blanco")
    end

    it 'no es válido con un título de más de 50 caracteres' do
      subject.title = 'a' * 51
      expect(subject).to_not be_valid
      expect(subject.errors[:title]).to include("es demasiado largo (50 caracteres máximo)")
    end

    it 'no es válido sin un cuerpo' do
      subject.body = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:body]).to include("no puede estar en blanco")
    end

    it 'no es válido con un cuerpo de más de 500 caracteres' do
      subject.body = 'a' * 501
      expect(subject).to_not be_valid
      expect(subject.errors[:body]).to include("es demasiado largo (500 caracteres máximo)")
    end

    it 'no es válido sin un nombre' do
      subject.name = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:name]).to include("no puede estar en blanco")
    end

    it 'no es válido con un nombre de más de 50 caracteres' do
      subject.name = 'a' * 51
      expect(subject).to_not be_valid
      expect(subject.errors[:name]).to include("es demasiado largo (50 caracteres máximo)")
    end

    it 'no es válido sin un correo' do
      subject.mail = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:mail]).to include("no puede estar en blanco")
    end

    it 'no es válido con un formato de correo inválido' do
      subject.mail = 'correo_invalido'
      expect(subject).to_not be_valid
      expect(subject.errors[:mail]).to include("no es válido")
    end

    it 'no es válido con un correo de más de 50 caracteres' do
      subject.mail = 'a' * 41 + '@example.com'
      expect(subject).to_not be_valid
      expect(subject.errors[:mail]).to include("es demasiado largo (50 caracteres máximo)")
    end

    it 'es válido con un teléfono en blanco' do
      subject.phone = ''
      expect(subject).to be_valid
    end

    it 'es válido con un teléfono en el formato correcto' do
      telefonos_validos = ['+56912345678', '+56987654321']
      telefonos_validos.each do |telefono_valido|
        subject.phone = telefono_valido
        expect(subject).to be_valid
      end
    end

    it 'no es válido con un teléfono de más de 20 caracteres' do
      subject.phone = '+569123456789012345678'
      expect(subject).to_not be_valid
      expect(subject.errors[:phone]).to include("es demasiado largo (20 caracteres máximo)")
    end

    it 'no es válido con un teléfono en un formato incorrecto' do
      telefonos_invalidos = ['12345678', '56912345678', '+569123456789', '+56912345', 'abcd+56912345678']
      telefonos_invalidos.each do |telefono_invalido|
        subject.phone = telefono_invalido
        expect(subject).to_not be_valid
        expect(subject.errors[:phone]).to include("El formato del teléfono debe ser +56XXXXXXXXX")
      end
    end
  end
end
