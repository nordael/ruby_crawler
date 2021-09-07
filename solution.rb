require 'json'
require 'mechanize'

url = 'http://veiculos.fipe.org.br/'
models = 'http://veiculos.fipe.org.br/api/veiculos/ConsultarModelos'
anoModelo = 'http://veiculos.fipe.org.br/api/veiculos/ConsultarAnoModelo'

mech = Mechanize.new
page = mech.get(url)

#cabeçalho do json resultante do web-crawl
json_solv = '{"HARLEY-DAVIDSON":{'

#obtém todos os modelos da marca HARLEY-DAVIDSON
resp_mod = mech.post( models,{  
    'codigoTipoVeiculo' => 2,
    'codigoTabelaReferencia' => 231, 
    'codigoMarca' => 77 
}).body

data = JSON::parse!(resp_mod.to_s)
models = []
cod_mdl = []
    
data["Modelos"].each do |mdl|
    models << mdl["Label"]   #recupera o nome de cada modelo
    cod_mdl << mdl["Value"]      #recupera o codigo do modelo
end

i = 0
str =''

cod_mdl.each do |v|
    #recupera a lista de anos associada a cada modelo
    resp_yrs = mech.post( anoModelo,{  
            'codigoTipoVeiculo' => 2,
            'codigoTabelaReferencia' => 231, 
            'codigoMarca' => 77,
            'codigoModelo' => v
            }).body
        
    #formata a lista para parsing    
    resp_yrs = '{"'+ models[i] +'":' + resp_yrs + '}'
    data = JSON::parse!(resp_yrs.to_s)
        
    str = '['
    #de cada modelo recupera o ano da lista formatada
    data[models[i]].each do |y|
        str =  str + y["Label"] + ','
    end
    #remove virgula residual
    str = str + ','
    str = str.match(",,").pre_match
        
    str = str + ']'
        
    #gera o JSON final
    json_solv = json_solv + '"' + models[i] + '":' + str + ","
    i = i+1
end
#remove virgula residual
json_solv = json_solv + ','
json_solv = json_solv.match(",,").pre_match
    
json_solv = json_solv + '}}'

file = File.open('solution.json', 'w')
file << json_solv
file.close_write