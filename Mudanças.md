# Mudanças que serão feitas comparado com o pré projeto

### Será adicionada mais uma tabela chamada "area_de_atuacao".

Para o usuário não receber todos os horários de coleta e motoristas registrados no mapa --- (e para uma certa optimização), será criado a tabela area_de_atuacao com um CEP. Os gerentes então colocarão quantos CEPs forem necessários para sua área de atuação, isso com o CEP. Segundo o [site dos correios](https://www.correios.com.br/enviar/precisa-de-ajuda/tudo-sobre-cep), o CEP será utilizado de qualquer forma conforme as necessidades do gerente.

Por exemplo, se a empresa atua no estado de São Paulo inteiro, o gerente apenas colocará "1" no CEP, correspondente ao estado de São Paulo.

Se a empresa apenas atua em Concórdia, será o CEP 897.

Também deverá colocar área de atuação em horarios de coleta, mas ainda tem que pensar sobre isso.

[Ainda em pesquisa]
Transformar coordenadas em CEP


### Criação de um sistema de Log

Para um melhor gerenciamento de erros e depurração, foi adicionado um sistema de Log que (supostamente) cria arquivos de log, gerando um histórico geral.

Os logs são gerados pela biblioteca winston. É criado um log diário com todos os logs (info, aviso e erros) e um só para erros. A pasta logs fica no diretório principal e foi colocada no .gitignore

### Criação de um aplicativo separado para o gerenciamento

Isso não estava constado no pré-projeto, mas é bom mencionar. O projeto foi dividido entre aplicativo padrão e aplicativo de gerenciamento, especialmente para ajudar no desenvolvimento.

### Mudanças menores

+ Adicionado coluna "tipo_lixo" na tabela "trajetorias"
+ Adicionado coluna "dia_da_semana" na tabela "horarios_coleta"
+ Adicionado coluna "id_gerente" na tabela "horarios_coleta"
+ Adicionado coluna "area_de_atuacao" na tabela "horarios_coleta"
+ Adicionado coluna "comentarios" na tabela "horarios_coleta"
+ Adicionado coluna "ativo" na tabela "horarios_coleta"
+ Adicionado endpoint "listarPorGerente" para a tabela de "horarios de coleta"

- Mudado a biblioteca "websocket" por "ws" por descontinuidade da biblioteca 'websocket'. (Mas fazem as mesmas coisas).