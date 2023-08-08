## Windows Remote Management 

**WinRM** is the Microsoft implementation of the WS-Management protocol, which is a standard Simple Object Access Protocol (SOAP)-based, firewall-friendly protocol that allows interoperation between hardware and operating systems from different vendors.

## Use the following commands to setup WinRM to work over HTTPS
1. Open `PowerShell` and type the following:
```bash
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
```
- *this changes the TLS version to 1.2*
- *For Windows 2019/2021 the default version is already TLS1.2 so you won't need to to this*

2. See if `WinRM` is enabled:
```bash
winrm quickconfig -quiet
```

3. Check `WinRM Listener`:
```bash
winrm enumerate winrm/config/listener
```

4. Setup Listener over HTTPS:
```bash
winrm quickconfig -transport:https
```

5. Connect to host using `WinRM`:
```bash
Enter-PSSession -ComputerName <FQDN> -UseSSL
```
* *if failed connection, remove* `-UseSSL`

## Server with SPN
If Windows server has a registered SPN (*Service Principal Name*) us the following to connect

```bash
$SessionOption = New-PSSessionOption -IncludePortInSPN
Enter-PSSession -ComputerName <FQDN> -SessionOption $SessionOption
```