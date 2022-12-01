object plataforma {
	const juegos = []
	
	method agregarJuego(juego){
		juegos.add(juego)
	}
		
	 ////////////////// PUNTO 2 //////////////////
	method aplicarDescuentoPorcentual(porcentaje)	 {	
		self.validarDescuento(porcentaje)
	 	const precioJuegoMasCaro = self.juegoMasCaro().precio()
		juegos.filter{j => j.precio() > 0.75 * precioJuegoMasCaro}
			.forEach{j => j.descuento(new DescuentoDirecto(porcentaje = porcentaje))}
	}
	 
	method juegoMasCaro() = juegos.max{j => j.precio()}

	method validarDescuento(porcentaje) {
		if (porcentaje >= 1)
			throw new Exception(message = "Descuento excesivo")
	}
	 //////////////////// INTERNACIONALIZACIÓN ////////////////////
	 
	method juegosAptosEn(pais) = juegos.filter{j => pais.esApto(j)}
	
	method promedioJuegosAptos(pais) {
		const juegosAptos = self.juegosAptosEn(pais) 
		return juegosAptos.sum{j => pais.conversionMonedaLocal(j.precio())} / juegosAptos.size()
	}	
	//////////////////////////////////// REVIEWS ////////////////////////////////////
	// PUNTO 3 //
	method hayAlgunJuegoGalardonado() = juegos.any{x => x.sinCriticasNegativas() }

}
class Juego {
	var property precioBase 
	var property descuento = descuentoNulo
	const caracteristicas = []
	const criticas = []
		
	////////////////// PUNTO 1 //////////////////
	method precio() = descuento.precio(self)

	//////////////// INTERNACIONALIZACION ////////////////

	method contieneCaracteristica(caracteristica) = caracteristicas.contains(caracteristica)
	method monedaLocal(pais) = pais
	
	//////////////////////////////////// REVIEWS ////////////////////////////////////
	// PUNTO 1//
	method recibirCriticaDe(critico){
		criticas.add(critico.criticar(self))
	}
	
	// PUNTO 2 //
	method cantidadCriticasPositivas() = criticas.count{x => x.positiva()}
		
	// PUNTO 3 //
	method sinCriticasNegativas() = criticas.all{x => x.positiva()}
	
	// PUNTO 4 //
	method tieneCriticaLiterario() = criticas.any{x => x.textoLargo()}
}

////////////////// DESCUENTOS //////////////////
class DescuentoDirecto {
	const porcentaje
	method precio(juego) = juego.precioBase() * (1 - porcentaje)
}

class DescuentoFijo {
	const montoFijo
	method precio(juego) = (juego.precioBase() - montoFijo).max(juego.precioBase() / 2)	
}

object descuentoGratis {
	method precio(juego) = 0
}

object descuentoNulo {
	method precio(juego) = juego.precioBase()
}

// DESCUENTO INVENTADO //
class DescuentoInventado inherits DescuentoDirecto {
	override method precio(juego) = super(juego)/2
}

//////////////////////// INTERNACIONALIZACIÓN //////////////////////////////////// 
class Pais {
	var cotizacionDolar
	const caracteristicasProhibidas = [] 
	
	method conversionMonedaLocal(importeEnDolares) = importeEnDolares / cotizacionDolar

	method esApto(juego) = 
		caracteristicasProhibidas.any{carac => juego.contieneCaracteristicas(carac)}
}

//////////////////////////////////// REVIEWS ////////////////////////////////////
class Critica {
	var property texto
	var property positiva

	// PUNTO 4 //
	method textoLargo() = texto.size() > 100
}

class Critico {
	method daCriticaPositiva(juego)
	method textoCritica()
	
	// PUNTO 1 //
	method criticar(juego) = new Critica(
		texto = self.textoCritica(),  
		positiva = self.daCriticaPositiva(juego)
	)
}

class Usuario inherits Critico{
	var property criticaPositiva = false

	override method textoCritica() = if (criticaPositiva) "Si" else "No"

	override method daCriticaPositiva(juego) = criticaPositiva
}

class CriticoPago  inherits Critico{
	const auspiciantes = []
	const textosPosibles = ["bueno","malo"]

	override method daCriticaPositiva(juego) = auspiciantes.contains(juego)
	
	override method textoCritica() = textosPosibles.anyOne()
	
	method agregarAuspiciante(juego){
		auspiciantes.add(juego)
	}
	
	method perderAuspiciante(juego) {
		auspiciantes.remove(juego)
	}
}

class Revista inherits Critico {
	const criticos = []

	override method daCriticaPositiva(juego) = 
		self.cantCriticosPositivos(juego) > criticos.size() / 2
	
	method cantCriticosPositivos(juego) = criticos.count{x => x.daCriticaPositiva(juego) }
	
	override method textoCritica() = criticos.fold("",{texto, critico => texto + "-" + critico.textoCritica()}).drop(1)

//	override method textoCritica(){
//		var texto = ""
//		criticos.forEach{critico => texto = texto + "-" + critico.textoCritica()}
//		return texto.drop(1)
//	}
	
	method agregarCritico(critico){
		criticos.add(critico)
	}
	
	method perderCritico(critico){
		criticos.remove(critico)
	}
}
