# data-act-build-tools

Ansible code for Data Broker configurations.

To install ansible, run:

    sudo pip install ansible

To run the web app, change to the data-broker-web-app directory within the repo and run:

    sudo ansible-playbook site-dev.yml -i "hosts" --private-key={path to pem file} -u ubuntu --extra-vars "branch={branch name}"