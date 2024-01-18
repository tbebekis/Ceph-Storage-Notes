 **AntyxSoft (tbebekis@antyxsoft.com)**

# Ansible Secrets and Vault

There is always the need to have passwords and other secrets protected somehow and pass
    those secrets as command line arguments in Ansible. Here is an example call for the `ansible-playbook` command.

**NOTE:** The `--extra-vars` parameter can be used to pass either a file with variables or variables as `key=value` pairs.

A secrets file, as the secrets.yml in the above example is a normal variables file, e.g.

Ansible comes with the `ansible-vault` command line tool. That tool can be used to encrypt/decrypt secret files and more.
     Here is the [ansible-vault documentation](https://docs.ansible.com/ansible/latest/cli/ansible-vault.html)

To encrypt a file

This will prompt for a password to be used in encrypting the file. And a confirmation for that password.
    The same password is used when decrypting the file.

That password may be stored in a simple text file. For example the next line creates a file named _ansible_vault_psw.txt_ and stores a password in it.

Then that password file can be used as in the first example.

Another way is to have the password file path in the _ansible.cfg_ file in a setting as

thus the `--vault-password-file` command line flag is no longer required, e.g.

When ansible is running a playbook, any time it comes across a .yml file that appears to be encrypted, 
     it will decrypt the file in memory and use that decrypted content.

Lets suppose there is a secrets.yml as

Encrypt that file as

and write down the password you provided or add a setting in _ansible.cfg_.

Then use that secrets.yml in a playbook as

To execute the playbook specifying the password file

To execute the playbook using the setting `vault_password_file=/path/to/ansible_vault_psw.txt` in the _ansible.cfg_, just

 
