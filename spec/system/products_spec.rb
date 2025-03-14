# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Products', type: :system do
  before do
    @user = User.create!(name: 'John1', password: 'Nonono123!', email: 'asdf@gmail.com',
                         role: 'admin')
    login_as(@user, scope: :user)
  end
  describe 'visiting the product form' do
    it 'have form' do
      visit '/products/crear'
      expect(page).to have_selector('h1', text: 'Crear Producto')
    end

    it 'creates a cancha' do
      visit '/products/crear'

      fill_in 'Nombre', with: 'Primera cancha'

      fill_in 'Precio', with: '1000'

      fill_in 'Stock', with: '15'

      fill_in 'Horarios', with: '12,13,14'

      click_on 'Guardar'

      expect(page).to have_content('Producto creado Correctamente !')
      expect(page).to have_current_path('/products/index')
    end

    it 'create a cancha but stock negative' do
      visit '/products/crear'

      fill_in 'Nombre', with: 'Primera cancha'

      fill_in 'Precio', with: '1000'

      fill_in 'Stock', with: '-15'

      fill_in 'Horarios', with: '12,13,14'

      click_on 'Guardar'

      expect(page).to have_content('Hubo un error al guardar el producto: Stock: debe ser mayor que o igual a 0')
      expect(page).to have_current_path('/products/crear')
    end

    it 'create a cancha but price negative' do
      visit '/products/crear'

      fill_in 'Nombre', with: 'Primera cancha'

      fill_in 'Precio', with: '-1000'

      fill_in 'Stock', with: '15'

      fill_in 'Horarios', with: '12,13,14'

      click_on 'Guardar'

      expect(page).to have_content('Hubo un error al guardar el producto: Precio: debe ser mayor que o igual a 0')
    end

    it 'create a cancha but price and stock negative' do
      visit '/products/crear'

      fill_in 'Nombre', with: 'Primera cancha'

      fill_in 'Precio', with: '-1000'

      fill_in 'Stock', with: '-15'

      fill_in 'Horarios', with: '12,13,14'

      click_on 'Guardar'

      expect(page).to have_content('Hubo un error al guardar el producto: Stock: debe ser mayor que o igual a 0,' \
                            ' Precio: debe ser mayor que o igual a 0')
    end

    it 'cancel the creation of a product' do
      visit '/products/crear'

      fill_in 'Nombre', with: 'Primera cancha'

      fill_in 'Precio', with: '-1000'

      fill_in 'Stock', with: '-15'

      fill_in 'Horarios', with: '12,13,14'

      click_on 'Cancelar'

      expect(page).to have_current_path('/products/index')
    end

    it 'update cancha' do
      visit '/products/crear'

      fill_in 'Nombre', with: 'Primera cancha'

      fill_in 'Precio', with: '1000'

      fill_in 'Stock', with: '15'

      fill_in 'Horarios', with: '12,13,14'

      click_on 'Guardar'

      visit '/products/index'

      expect(page).to have_css('.card')

      within('.card', match: :first) do
        click_on 'Editar'
      end
      expect(find_field('Nombre').value).to eq('Primera cancha')
      expect(find_field('Precio').value).to eq('1000')
      expect(find_field('Stock').value).to eq('15')

      fill_in 'Nombre', with: 'Primera cancha actualizada'
      fill_in 'Precio', with: '2000'
      fill_in 'Stock', with: '20'

      click_on 'Guardar'

      cancha = Product.order(created_at: :desc).first

      expect(cancha.nombre).to eq('Primera cancha actualizada')
      expect(cancha.precio).to eq('2000')
      expect(cancha.stock).to eq('20')
    end
    it 'update cancha but no name' do
      visit '/products/crear'

      fill_in 'Nombre', with: 'Primera cancha'

      fill_in 'Precio', with: '1000'

      fill_in 'Stock', with: '15'

      fill_in 'Horarios', with: '12,13,14'

      click_on 'Guardar'

      visit '/products/index'

      expect(page).to have_css('.card')

      within('.card', match: :first) do
        click_on 'Editar'
      end

      fill_in 'Nombre', with: ''

      click_on 'Guardar'

      expect(page).to have_content('Hubo un error al guardar el producto. Complete todos los campos solicitados!')
      expect(find_field('Nombre').value).to eq('Primera cancha')
      expect(find_field('Precio').value).to eq('1000')
      expect(find_field('Stock').value).to eq('15')
    end

    it 'update cancha but negative stock' do
      visit '/products/crear'

      fill_in 'Nombre', with: 'Primera cancha'

      fill_in 'Precio', with: '1000'

      fill_in 'Stock', with: '15'

      fill_in 'Horarios', with: '12,13,14'

      click_on 'Guardar'

      visit '/products/index'

      expect(page).to have_css('.card')

      within('.card', match: :first) do
        click_on 'Editar'
      end

      fill_in 'Stock', with: '-20'

      click_on 'Guardar'

      expect(page).to have_content('Hubo un error al guardar el producto. ' \
                                   'Complete todos los campos solicitados!')
      expect(find_field('Nombre').value).to eq('Primera cancha')
      expect(find_field('Precio').value).to eq('1000')
      expect(find_field('Stock').value).to eq('15')
    end

    it 'update cancha but cancel' do
      visit '/products/crear'

      fill_in 'Nombre', with: 'Primera cancha'

      fill_in 'Precio', with: '1000'

      fill_in 'Stock', with: '15'

      fill_in 'Horarios', with: '12,13,14'

      click_on 'Guardar'

      visit '/products/index'

      expect(page).to have_css('.card')

      within('.card', match: :first) do
        click_on 'Editar'
      end

      click_on 'Cancelar'

      expect(page).to have_current_path('/products/index')
    end

    it 'crear una pregunta' do
      visit '/products/crear'

      fill_in 'Nombre', with: 'Primera cancha'

      fill_in 'Precio', with: '1000'

      fill_in 'Stock', with: '15'

      fill_in 'Horarios', with: '12,13,14'

      click_on 'Guardar'

      visit '/products/index'

      expect(page).to have_css('.card')

      within('.card', match: :first) do
        click_on 'Detalles'
      end
      fill_in 'message[body]', with: 'Hola soy un mensaje'
      click_on 'Crear'
      new_message = Message.order(created_at: :desc).first
      expect(new_message.body).to eq('Hola soy un mensaje')
    end

    it 'not allowed on the product form' do
      logout(:user)
      visit '/products/crear'
      expect(page).to have_selector('div', text: 'No estás autorizado para acceder a esta página')
    end
  end
end
