class LoadIngramCategories < ActiveRecord::Migration[5.0]
  CATEGORIES = [
    ["","https://www.imstores.com/Ingrammicromx/ProductSearch.aspx?MatrixKey=A1001"],
    ["Accesorios y Componentes","https://www.imstores.com/Ingrammicromx/ProductSearch.aspx?MatrixKey=99"],
    ["Almacenamiento","https://www.imstores.com/Ingrammicromx/ProductSearch.aspx?MatrixKey=A1005"],
    ["Audio / Video","https://www.imstores.com/Ingrammicromx/ProductSearch.aspx?MatrixKey=A1008"],
    ["Componentes","https://www.imstores.com/Ingrammicromx/ProductSearch.aspx?MatrixKey=A1002"],
    ["Computadoras","https://www.imstores.com/Ingrammicromx/ProductSearch.aspx?MatrixKey=00"],
    ["Dispositivos de Almacenamiento","https://www.imstores.com/Ingrammicromx/ProductSearch.aspx?MatrixKey=02"],
    ["Dispositivos de Entrada / Salida","https://www.imstores.com/Ingrammicromx/ProductSearch.aspx?MatrixKey=A1006"],
    ["Dispositivos de Video","https://www.imstores.com/Ingrammicromx/ProductSearch.aspx?MatrixKey=A1004"],
    ["Electrodomésticos","https://www.imstores.com/Ingrammicromx/ProductSearch.aspx?MatrixKey=50"],
    ["Equipamiento Telefónico","https://www.imstores.com/Ingrammicromx/ProductSearch.aspx?MatrixKey=A1003"],
    ["Gaming","https://www.imstores.com/Ingrammicromx/ProductSearch.aspx?MatrixKey=A1017"],
    ["Impresoras, Plotters y Eq de Oficina","https://www.imstores.com/Ingrammicromx/ProductSearch.aspx?MatrixKey=07"],
    ["Joyería","https://www.imstores.com/Ingrammicromx/ProductSearch.aspx?MatrixKey=60"],
    ["Protección Eléctrica","https://www.imstores.com/Ingrammicromx/ProductSearch.aspx?MatrixKey=A1014"],
    ["Punto de Venta, AIDC y Código de Barras","https://www.imstores.com/Ingrammicromx/ProductSearch.aspx?MatrixKey=90"],
    ["Redes","https://www.imstores.com/Ingrammicromx/ProductSearch.aspx?MatrixKey=A1009"],
    ["Seguridad Física","https://www.imstores.com/Ingrammicromx/ProductSearch.aspx?MatrixKey=16"],
    ["Servicios y Garantías","https://www.imstores.com/Ingrammicromx/ProductSearch.aspx?MatrixKey=A1013"],
    ["Servidores","https://www.imstores.com/Ingrammicromx/ProductSearch.aspx?MatrixKey=A1012"],
    ["Software","https://www.imstores.com/Ingrammicromx/ProductSearch.aspx?MatrixKey=15"],
    ["Suministros","https://www.imstores.com/Ingrammicromx/ProductSearch.aspx?MatrixKey=10"]
  ]

  def up
    CATEGORIES.each do |name, url|
      IngramCategory.create(name: name, url: url)
    end
  end

  def down
    CATEGORIES.each do |name, _|
      IngramCategory.find_by_name(name).destroy
    end
  end
end
