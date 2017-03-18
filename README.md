# Installation
```
sudo apt-get update
sudo apt-get install git carton libssl-dev build-essential

cd <project_folder>
carton
cp emails_collector.sample.conf emails_collector.conf
edit emails_collector.conf

carton run morbo -w . script/emails_collector # dev mode
```


