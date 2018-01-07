# Overview
This project has been created to provide an offline demo of the Red Hat [CloudForms][1] (CFME) appliance.
This Dockerfile instantiates CFME 4.2 as a container, and then imports the database dump from the environment in the MBU lab.

```sh
wget -N http://10.9.62.89/dumps/42/vmdb_production_latest.dump -P test/test-app
```

[1]: https://access.redhat.com/containers/#/search/cfme
