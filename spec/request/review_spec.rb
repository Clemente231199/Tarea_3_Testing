# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReviewController, type: :controller do
  before do
    @user = User.create!(name: 'John1', password: 'Nonono123!', email: 'asdf@gmail.com',
                         role: 'admin')
    sign_in @user
    @product = Product.create!(nombre: 'John1', precio: 4000, stock: 1, user_id: @user.id, categories: 'Cancha')

    @review = Review.create(
      product_id: @product.id,
      user_id: @user.id,
      tittle: 'Old Review',
      description: 'This is an old review',
      calification: 3
    )
  end

  describe 'POST #insertar' do
    context 'con parámetros válidos' do
      it 'crea una nueva reseña y redirige a la página del producto' do
        expect do
          post :insertar, params: {
            product_id: @product.id,
            tittle: 'Test Review',
            description: 'This is a test review',
            calification: 4
          }
        end.to change(Review, :count).by(1)

        expect(flash[:notice]).to eq('Review creado Correctamente !')
        expect(response).to redirect_to("/products/leer/#{@product.id}")
      end
    end

    context 'con parámetros inválidos' do
      it 'no crea una nueva reseña y redirige a la página del producto' do
        expect do
          post :insertar, params: {
            product_id: @product.id,
            tittle: '', # título vacío
            description: 'This is a test review',
            calification: 4
          }
        end.not_to change(Review, :count)

        expect(flash[:error]).to eq('Hubo un error al guardar la reseña; debe completar todos los campos solicitados.')
        expect(response).to redirect_to("/products/leer/#{@product.id}")
      end
    end
  end

  describe 'PATCH #actualizar_review' do
    context 'con parámetros válidos' do
      it 'actualiza la reseña y redirige a la página del producto' do
        patch :actualizar_review, params: {
          id: @review.id,
          tittle: 'Updated Review',
          description: 'This is an updated review',
          calification: 5
        }

        @review.reload
        expect(@review.tittle).to eq('Updated Review')
        expect(@review.description).to eq('This is an updated review')
        expect(@review.calification).to eq('5')
        expect(response).to redirect_to("/products/leer/#{@product.id}")
      end
    end

    context 'con parámetros inválidos' do
      it 'no actualiza la reseña y redirige a la página del producto' do
        patch :actualizar_review, params: {
          id: @review.id,
          tittle: '',
          description: 'This is an updated review',
          calification: 5
        }

        @review.reload
        expect(@review.tittle).to eq('Old Review')
        expect(flash[:error]).to eq('Hubo un error al editar la reseña. Complete todos los campos solicitados!')
        expect(response).to redirect_to("/products/leer/#{@product.id}")
      end
    end
  end

  describe 'DELETE #eliminar' do
    before do
      @review = Review.create(
        product_id: @product.id,
        user_id: @user.id,
        tittle: 'Review to delete',
        description: 'This is a review to delete',
        calification: 2
      )
    end

    it 'elimina la reseña y redirige a la página del producto' do
      expect do
        delete :eliminar, params: { id: @review.id }
      end.to change(Review, :count).by(-1)

      expect(response).to redirect_to("/products/leer/#{@product.id}")
    end
  end
end
