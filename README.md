# unraid-api

Simple powershell script to create an api endpoint to pull the PSU data from unraid.

## Requirements
- https://forums.unraid.net/topic/86715-corsair-rmi-hxi-axi-psu-statistics-cyanlabss-fork/
- Corsair AXI PSU

Endpoints

| Health | unraid | end |
| ------ | ------ | ------ | 
| Health Status | PSU Output | kill process

![image](https://user-images.githubusercontent.com/74198206/196565913-315ca0dc-a577-4ee7-9262-7af98f2d485c.png)


## How to Run

```bash
sudo docker run -p 8000:8000 -e password=<RootPassword> -e uri=<URL to access unraid (Without HTTP or HTTPS)> ghcr.io/developerdurp/unraid-api:latest
```