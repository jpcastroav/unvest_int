class NoticiasController < ApplicationController
  @@url = ENV.fetch("APIGW_URL", "http://localhost:5500/graphql")
  soap_service namespace: 'urn:WashOutNoticia', camelize_wsdl: :lower

  soap_action "obtenerNoticias",
				:args   => { :ticker => :string },
				:return => { :noticias => { noticia: [{:etiqueta_sentimiento_general => :string, :fecha_publicacion => :string, :fuente => :string, :imagen_banner => :string, :puntuacion_sentimiento_general => :float, :resumen => :string, :titulo => :string, :url => :string}]} }  #{ :noticias :articulo => {:etiqueta_sentimiento_general => :string, :fecha_publicacion => :string, :fuente => :string, :imagen_banner => :string, :puntuacion_sentimiento_general => :float, :resumen => :string, :titulo => :string, :url => :string}}
	def obtenerNoticias
		response = HTTParty.post(
			@@url,
			headers: {
				"content-type" => "application/json"
			},
			body: <<-JSON
				{"query": "{noticiaByTicker ( ticker: \\\"#{params[:ticker]}\\\" ) { article {  etiqueta_del_sentimiento_general Fecha_de_publicacion fuente imagen_del_banner puntuacion_del_sentimiento_general Resumen titulo url } }  }",
        "variables": null,
        "operationName": null
        }
			JSON
		)

    body = JSON.parse(response.body)
    noticias = body["data"]["noticiaByTicker"].map {|result| {etiqueta_sentimiento_general: result["article"]["etiqueta_del_sentimiento_general"], fecha_publicacion: result["article"]["Fecha_de_publicacion"], fuente: result["article"]["fuente"], imagen_banner: result["article"]["imagen_del_banner"], puntuacion_sentimiento_general: result["article"]["puntuacion_del_sentimiento_general"], resumen: result["article"]["Resumen"], titulo: result["article"]["titulo"], url: result["article"]["url"]}}

		render :soap => {noticias: {noticia: noticias}}
	end
end
