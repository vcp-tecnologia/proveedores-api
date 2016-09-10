class ProductsController < ApplicationController
  before_filter :filter_params, only: [:productos]
  has_scope :fecha
  has_scope :categoria
  has_scope :subcategoria
  has_scope :proveedor
  has_scope :id_proveedor

  def productos
    @products = apply_scopes(Product).all
    products = @products.pluck(:data, :updated_at).each.map do |productData, modDate|
      data = JSON.parse(productData)
      data[:fecha] = modDate.strftime("%F")
      data      
    end
    render json: products
  end

  def proveedores
    render json: {
      proveedores: ['Ingram']
    }
  end

  private 

  def filter_params
    params.permit(:proveedor, :fecha, :categoria, :subcategoria, :id_proveedor)
  end
end
