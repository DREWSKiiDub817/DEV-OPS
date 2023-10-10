## Service Principal Name

A **service principal name** (SPN) is a unique identifier of a service instance. Kerberos authentication uses SPNs to associate a service instance with a service sign-in account. Doing so allows a client application to request service authentication for an account even if the client doesn't have the account name.

- Format:  
Service Name / Host Name: Port Number  
i.e. HTTP/Server1.domain: 5985
- SPNs are stored in AD in the servicePrincipalName attribute of a user or computer object.
- Registered by services running on a computer or by an application or manually by an administrator of an application.

## Connect to server with SPN

```bash
$SessionOption = New-PSSessionOption -IncludePortInSPN
Enter-PSSession -ComputerName <FQDN> -SessionOption $SessionOption
```
