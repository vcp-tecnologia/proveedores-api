class ProductsController < ApplicationController
  include ActionController::HttpAuthentication::Basic::ControllerMethods
  http_basic_authenticate_with name: Rails.application.config.basic_auth_username, password: Rails.application.config.basic_auth_password

  before_filter :filter_params, only: [:productos]
  has_scope :proveedor
  has_scope :fecha
  has_scope :categoria
  has_scope :subcategoria
  has_scope :id_proveedor
  has_scope :fabricante

  PAGE_SIZE = 50

  def productos
    pageSize = params[:resultados_por_pagina] || PAGE_SIZE
    totalPages = (apply_scopes(Product).complete_data.count / pageSize.to_f).ceil
    page = params[:page] ? params[:page].to_i : 1
    @products = apply_scopes(Product).complete_data.paginate(:page => page, :per_page => pageSize)
    products = @products.pluck(:data, :updated_at, :price, :units).each.map do |productData, modDate, price, units|
      data = JSON.parse(productData)
      data[:fecha_acualizado] = modDate.strftime("%F")
      data[:precio] = price
      data[:existencias] = units
      data      
    end
    render json: {
      pagina: page,
      total_paginas: totalPages,
      numero_de_resultados: products.size,
      products: products
    }
  end

  def proveedores
    proveedores = Product.select(:vendor).distinct.pluck(:vendor)
    proveedores = [] if proveedores == [nil]
    render json: {
      proveedores: proveedores
    }
  end

  private 

  def filter_params
    params.permit(:proveedor, :fecha, :categoria, :subcategoria, :id_proveedor, :fabricante, :page)
  end
end
