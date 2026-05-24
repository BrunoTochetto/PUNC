# Mudanças que serão feitas comparado com o pré projeto

### Será adicionada mais uma tabela chamada "areaDeAtuação" e a coluna "id_areaAtuacao" para o gerente.

Para o usuário não receber todos os horários de coleta e motoristas registrados (e para uma certa optimização), será criado a tabela area_de_atuacao com um CEP. Os gerentes então vão colocar quantos CEPs forem necessários para mover sua área de atuação, isso com o CEP. Segundo o [site dos correios](https://www.correios.com.br/enviar/precisa-de-ajuda/tudo-sobre-cep), o CEP será utilizado de qualquer forma conforme as necessidades do gerente.

Por exemplo, se a empresa atua no estado de São Paulo inteiro, o gerente apenas colocará "1" no CEP, correspondente ao estado de São Paulo.

Se a empresa apenas atua em Concórdia, será o CEP 897.

[Ainda em pesquisa]
Se nós não conseguirmos transformar Coordenadas geográficas para CEP, o usuário terá q colocar seu CEP... Se for o caso, a localização por parte do usuário não servirá de nada.


### Criação de um sistema de Log

Para um melhor gerenciamento de erros e depurração, foi adicionado um sistema de Log que (supostamente) cria arquivos de log, gerando um histórico geral.

Os logs são gerados pela biblioteca winston. É criado um log diário com todos os logs (info, aviso e erros) e um só para erros. A pasta logs fica no diretório principal e foi colocada no .gitignore
