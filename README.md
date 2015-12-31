# data-act-build-tools

Ansible code for Data Broker configurations.

To install ansible, run:

    sudo pip install ansible

To run the web app, run:

    sudo ansible-playbook data-broker-web-app/site-dev.yml -i "data-broker-web-app/hosts" --private-key={path to pem file} -u ubuntu --extra-vars "branch={branch name}"