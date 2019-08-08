![cam-tecnologia](https://user-images.githubusercontent.com/16817969/62732643-43fb8e00-b9fb-11e9-8f04-af29c1f6d8bb.jpg)

### INSTALAÇÃO CAMBOX - CAM TECNOLOGIA EIRELI -ME 

O foco da CAM Tecnologia ao realizar revenda de equipamentos é oferecer a seus clientes uma solução completa de serviços e equipamentos para TIC.

> Endereço: 

Pastor Martin Luther King Jr. BLC 09 Sala 326     
Del. Castilho, Rio de Janeiro - RJ, Brasil - BR, CEP: 20.765-000                      

##### SCRIPTS DESENVOLVIDO PELA EQUIPE DE SUPORTE CAM TECNOLOGIA

<ol>
  <li>Software Disponível - ISSABEL</li>
  <li>Link para Realizar o Download da ISO - ISSABEL https://www.issabel.org/</li>
</ol>


<ol>
  <li>Bootar o Pendrive com - ISSABEL</li>
  <li>Selecionar Versão 11</li>
  <li>Na Tela que Tá Demorando Muito Tecle [ESC]</li>
  <li>Dracut: /# (Digite Exit)</li>
</ol>

#### Tela de Instalação no Hardware CAMBOX Físico

- 01 - Tela Inicial da Instalação ISSABEL;

![01 Tela de Instalação ISSABEL](https://user-images.githubusercontent.com/16817969/62736589-15ce7c00-ba04-11e9-9190-7450d7023fc4.png)

- 02 - Tela de Boas Vindas - ISSABEL, Localize o Idioma que quer Usar;

![02 Tela de Instalação ISSABEL](https://user-images.githubusercontent.com/16817969/62737291-d30da380-ba05-11e9-8fb8-c175c0987884.png)

- 03 - Tela de Resumo da Instalação;

![03 Tela de Instalação ISSABEL](https://user-images.githubusercontent.com/16817969/62738085-cf7b1c00-ba07-11e9-8239-cc8d7281f151.png)

- 04 - Tela Data e Hora;

![04 Tela de Instalação ISSABEL](https://user-images.githubusercontent.com/16817969/62738469-c179cb00-ba08-11e9-949b-d2363a800467.png)

- 05 - Tela Layout do Teclado;

![05 Tela de Instalação ISSABEL](https://user-images.githubusercontent.com/16817969/62738476-c76fac00-ba08-11e9-8f90-2ec3ce07eded.png)

- 06 - Tela Suporte a Idiomas;

![06 Tela de Instalação ISSABEL](https://user-images.githubusercontent.com/16817969/62738483-cb033300-ba08-11e9-9dd3-6b99c8bc945d.png)

- 07 - Tela Fonte de Instalação;

![07 Tela de Instalação ISSABEL](https://user-images.githubusercontent.com/16817969/62738488-cfc7e700-ba08-11e9-9427-cde9796a65bc.png)

- 08 - Tela Seleção de Software;

![08 Tela de Instalação ISSABEL](https://user-images.githubusercontent.com/16817969/62738498-d5bdc800-ba08-11e9-9a39-6ea31bb41b7c.png)




<ol>
  <li>Na Interface</li>
  <li>Data e Hora</li>
  <li>Teclado</li>
</ol>


# >> >> 04 >> Destino Instalação: Desmarcar PenDrive, Marcar Configurar Automaticamente, Recuperar Espaço
# >> >> 05 >> Recuperar Espaço: Apagar Tudo e Recuperar Espaço

- 06 Rede e Nome (Ativa eth0 => ON)
- 07 Senha Raiz e do MariaDB (Senha do root => mysql.admin)
- 08 Toda vez que for executado esse comando será obrigatorio realizar o processo 
- 08 # sudo yum update -y && sudo yum upgrade -y
# >> >> 09 >> Configuração SELINUX e Firewall 
# >> >> >> 08.02 >> # vim /etc/selinux/config ou sudo systemctl disable firewalld 
# >> >> >> >> Esse comando é para desabilitar o Firewall e quando reiniciar a máquina não precisar usar o # iptables -F

# Reiniciar o Servidor Após a Configuraço
# >> >> 10 >> Criação de Usuário root (cam) 
# >> >> >> 10.01 >> # vim /etc/sudoers (cam       ALL=(ALL)       ALL)
# >> >> 11 >> Configuração da Rede
# >> >> >> 11.01 >> # systemctl enable dhcpd && /etc/init.d/netword restart


