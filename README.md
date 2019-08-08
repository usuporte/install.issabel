### INSTALAÇÃO CAMBOX - CAM TECNOLOGIA EIRELI -ME 

O foco da CAM Tecnologia ao realizar revenda de equipamentos é oferecer a seus clientes uma solução completa de serviços e equipamentos para TIC.

> Endereço: 

Pastor Martin Luther King Jr. BLC 09 Sala 326     
Del. Castilho, Rio de Janeiro - RJ, Brasil - BR, CEP: 20.765-000                      

##### SCRIPTS DESENVOLVIDO PELA EQUIPE DE SUPORTE CAM
```
- 00 Software Disponível (ISSABEL)
- 00.01 ***Link***: https://www.issabel.org/

- 01 Bootar o Pendrive com ISSABEL
- 02 Selecionar Versão 11
- 03 Na Tela que Tá Demorando Muito Tecle [ESC]
- 04 Dracut: /# (Digite Exit)

- 05 Na Interface:  
- 05.01 Data e Hora
- 05.02 Teclado

# >> >> 04 >> Destino Instalação: Desmarcar PenDrive, Marcar Configurar Automaticamente, Recuperar Espaço
# >> >> 05 >> Recuperar Espaço: Apagar Tudo e Recuperar Espaço

- 06 Rede e Nome (Ativa eth0 => ON)
- 07 Senha Raiz e do MariaDB (Senha do root => mysql.admin)
- 08 Toda vez que for executado esse comando será obrigatorio realizar o processo 
- 08 # sudo yum update -y && sudo yum upgrade -y
# >> >> 09 >> Configuração SELINUX e Firewall 
# >> >> >> 08.02 >> # vim /etc/selinux/config ou sudo systemctl disable firewalld 
# >> >> >> >> Esse comando é para desabilitar o Firewall e quando reiniciar a máquina não precisar usar o # iptables -F



```

