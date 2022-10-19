FROM mcr.microsoft.com/powershell:latest
COPY pwsh-api.ps1 /
EXPOSE 8000
CMD pwsh /pwsh-api.ps1 -password $password -uri $uri