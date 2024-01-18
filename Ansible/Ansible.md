[Ansible](https://www.ansible.com) is an open source suite of tools used in application deployment, configuration management and cloud provisioning. Ansible connects to the hosts it manages, using temporary SSH connections. It executes without using agents in the managed hosts. It just pushes modules to the managed hosts, executes a script, called Playbook, and erases the modules. Ansible playbooks are written in [YAML](https://en.wikipedia.org/wiki/YAML).

Ansible runs on many linux distributions and in [WSL](https://en.wikipedia.org/wiki/Windows_Subsystem_for_Linux) in MS Windows.

## An easy way to test Ansible

An easy way to test Ansible is to use [VirtualBox](https://en.wikipedia.org/wiki/VirtualBox).

Create a control host [VM](https://en.wikipedia.org/wiki/Virtual_machine) (i.e. the host from which to run the Ansible CLI tools) by using a handy Linux distribution, such as [Ubuntu](https://en.wikipedia.org/wiki/Ubuntu) or [Linux Mint](https://en.wikipedia.org/wiki/Linux_Mint).

For managed hosts refer to [this guide](https://www.how2shout.com/linux/install-ubuntu-20-04-22-04-cloud-image-minimal-on-virtualbox/) in order to create one or more [VM](https://en.wikipedia.org/wiki/Virtual_machine)s running a minimal Ubuntu image.

## An arrangement

A handy way to work with Ansible is the following.

Install Ansible on control host.

```
# Ubuntu - Linux Mint
apt update
apt install software-properties-common
add-apt-repository --yes --update ppa:ansible/ansible
apt install ansible # /usr/lib/python3/dist-packages/ansible

# CentOS
yum install epel-release
yum install ansible  

# check the version
ansible --version
```

Configure static IPs for control and managed hosts. For example

```
sudo nmcli connection add type ethernet con-name enp0s3 ifname enp0s3 ipv4.addresses 192.168.2.9/24 ipv4.gateway 192.168.2.1
```

In control host edit the `/etc/hosts` file, by adding the managed hosts.

```
127.0.0.1 localhost
127.0.1.1 control-host
192.168.2.9 managed-host-0
192.168.2.10 managed-host-1
```

Generate a ssh key and copy the ssh key to all managed hosts

```
ssh-keygen

ssh-copy-id user@managed-host-0
ssh-copy-id user@managed-host-1
```

In control host, `cd` to `/home/USER` and create a work folder, e.g.

```
cd ~
mkdir Ansible
```

Inside that work folder place `ansible.cfg`, `hosts` and `test.yml` files with the following content

**ansible.cfg**

```
[defaults]
inventory = hosts
```

**hosts file**

```
[servers]
managed-host-0
managed-host-1
```

**test.yml**

```
- name: A test play
  hosts: servers
  tasks:
  - name: Ping hosts
    ansible.builtin.ping:
  - name: Print a message
    ansible.builtin.debug:
      msg: Hello world
```

Finally, execute the test Playbook.

```
cd ~/Ansible
ansible-playbook test.yml
```


## Ansible concepts

- **Control host**. The host from which Ansible CLI tools are executed.
- **Managed hosts**. The target devices (servers, network appliances or any computer) managed with Ansible.
- **Inventory**. The list of hosts managed by Ansible.
- **Playbook**. A collection of Plays in a YAML file.
- **Play**. Contains variables, roles and an ordered list of Tasks. <!--more-->
- **Task**. An action to be applied to a managed host, e.g. install a software package.
- **Handler**. A special Task. It executes only when notified by a previous Task which resulted in a "changed" status.
- **Module**. A code or a binary unit that is copied and executed on each managed node in order to apply a Task.
- **Role**. A reusable group of Ansible objects such as Tasks, Handlers, Variables, Plugins, Templates and Files for use inside of a Play.
- **Collection**. A format of a package that is distributed through [Ansible Galaxy](https://galaxy.ansible.com) and can contain Playbooks, Roles, Modules, and Plugins.
- **Plugin**. A unit of software that extends Ansible's capabilities.

## Configuration

Ansible provides documentation about [configuration](https://docs.ansible.com/ansible/latest/reference_appendices/config.html) and also a default [configuration file](https://github.com/ansible/ansible/blob/stable-2.9/examples/ansible.cfg).

The filename of the configuration file is `ansible.cfg`.

There is no default Ansible configuration file created by default. Ansible does not create any system wide configuration file at installation time.

Ansible searches for a configuration file in the following order:

- `ANSIBLE_CONFIG`  (environment variable if set)
- `ansible.cfg`  (in the current directory)
- `~/.ansible.cfg`  (in the home directory)
- `/etc/ansible/ansible.cfg`

The `ansible.cfg` has the format of an `*.ini` file. It contains sections, e.g. `[defaults]`, and `KEY = VALUE` settings. The `#` character in the beginning of a line, denotes a comment.

```
# EXAMPLE - defines the inventory file path
[defaults]
inventory = /path/to/inventory/file
```

If Ansible is run without any existing configuration file it uses hard-coded default values for all parameters.

```
# display configuration settings
ansible-config dump

# To create an ansible.cfg file  containing commented out default values of all known parameters 
# and store it in a folder
ansible-config dump > ansible.cfg 

```

## Inventory file (hosts file)

Documentation regarding [inventory file](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html).

Default location of the inventory file is at `/etc/ansible/hosts`. Ansible installation does **not** create this file. It must be created manually.

Better is **not**  to use the default `/etc/ansible/hosts`. Instead create a work folder, say `Ansible` and place inside that folder all needed files, such as `ansible.cfg`, `hosts` and any playbook `*.yml` file. Set the path to inventory file in `ansible.cfg`.

```
# EXAMPLE - defines the inventory file path
[defaults]
inventory = /path/to/inventory/file
```

Many ways to define the inventory file.

```
# you can create the default hosts file
nano /etc/ansible/hosts

# or set ANSIBLE_INVENTORY environment variable to point to a hosts file
export ANSIBLE_INVENTORY=path/to/inventory/file

# or pass a hosts file with the -i parameter to ansible or ansible-playbook commands
ansible-playbook playbook.yml -i path/to/inventory/file
```

Some useful Ansible commands, related to inventory file.

```
# verify hosts
ansible all --list-hosts [-i /path/to/inventory/file]

# get help
ansible-inventory --help

# display hosts graph
ansible-inventory --graph

# host and vars graph
ansible-inventory --graph --vars

# in json format
ansible-inventory -list

# information
ansible-inventory --host HOST_IP_OR_NAME
```

An example of an inventory file with variables.

```
# CAUTION: do NOT use - in group names, e.g. [my-hosts]

[group1]
192.168.2.10 http_port=80  maxRequestsPerChild=808
ubuntu-min-0 http_port=303 maxRequestsPerChild=909

[group1:vars]
ntp_server=ntp.example.com
proxy=proxy.example.com
```

## The `ad hoc` commands

Check the provided [documentation](https://docs.ansible.com/ansible/latest/user_guide/intro_adhoc.html)

The term `ad hoc` commands refers to the use of `ansible` command in order to execute a single Task in one or more managed hosts. 

Although `ad hoc`is an easy way to quickly execute a Task, it is not reusable.

The syntax is

```
ansible [pattern] -m [module] -a "[module options]"
```

The `[pattern]` is a [pattern](https://docs.ansible.com/ansible/latest/user_guide/intro_patterns.html) used in specifying the managed hosts or host groups you want to execute against.

The `-m` flag used in specifying the module to be used, say `copy`.

The `-a` flag used in specifying the arguments to the command, say `"name=httpd state=restarted"`.

Here is an example call that restarts the Apache service in a group of managed hosts, defined in the `hosts` file, under the name `webservers`.

```
ansible webservers -m service -a "name=httpd state=restarted"
```

Here is another example that copies a file from the control host to all managed hosts of the `webservers` group.
```
ansible webservers -m copy -a "src=/tmp/my-file dest=/tmp/my-file"
```

## Playbook execution

The syntax is

```
ansible-playbook -i /path/to/inventory/file -u SSH_USER -f 10 -t TAG_NAME -b -K /path/to/playbook/file
```

The above executes the specified Playbook with the following options:

- `-i` uses the specified inventory file.
- `-u` connects over SSH using the specified user.
- `-f` allocates 10 forks (threads).
- `-t` executes only those tasks marked with the tag TAG_NAME.
- `-b` executes with elevated privileges (uses become).
- `-K` prompts the user for the become password.

More information can be found in `ansible-playbook` [documentation](https://docs.ansible.com/ansible/latest/cli/ansible-playbook.html).

## Playbooks

A Playbook is a YAML file. A Playbook is an ordered list of one or more Plays. A Play is an ordered list of one or more Tasks. A Task uses a Module to execute its action.

A Playbook runs from top to bottom. Plays and Tasks run from top to bottom.

A Play defines the managed nodes to target, using the `hosts` keyword, and at least one Task to execute.

The following example is taken from [Ansible documentation](https://docs.ansible.com/ansible/latest/user_guide/playbooks_intro.html).

```
- name: Update web servers
  hosts: webservers
  remote_user: root

  tasks:
  - name: Ensure apache is at the latest version
    ansible.builtin.yum:
      name: httpd
      state: latest
  - name: Write the apache config file
    ansible.builtin.template:
      src: /srv/httpd.j2
      dest: /etc/httpd.conf

- name: Update db servers
  hosts: databases
  remote_user: root

  tasks:
  - name: Ensure postgresql is at the latest version
    ansible.builtin.yum:
      name: postgresql
      state: latest
  - name: Ensure that postgresql is started
    ansible.builtin.service:
      name: postgresql
      state: started
```

The above example is a Playbook with two Plays. Each Play defines two Tasks.

The first Play targets the `webservers` hosts, installs Apache and sets the `httpd.conf` Apache configuration file.

The second Play targets the `databases` hosts, installs PostgreSQL and starts the service after installation.

The `hosts` and `remote_user` are Playbook **keywords**. Keywords can be used in Playbook, Play and Task level. For a full list of Playbook **keywords** consult the [documentation](https://docs.ansible.com/ansible/latest/reference_appendices/playbooks_keywords.html).

Ansible executes using the following logic: a Task is executed against all specified hosts. When the Task is finished execution, then Ansible moves on to the next Task.

A Task uses a module, such as `ansible.builtin.yum`, or just `yum`, in order to apply its action. Most modules will not be executed if the desired state is already achieved. So running the Task again will not change the final state of the host.

## YAML syntax

Please check the provided [documenation](https://docs.ansible.com/ansible/latest/reference_appendices/YAMLSyntax.html).

A YAML file  can optionally begin with `---` and end with `....`.

The YAML format uses identation to indicate the level of an entry. For identation use spaces and **not** tabs.

#### Lists

A list is defined by placing each entry in its own line, in the same identation level. Each entry in the list begins with a hyphen and a space.

```
parts:
  - one
  - two
  - three
 ```

Abbreviated form.

```
parts: [one, two, three]
```

#### Dictionaries

A dictionary is a list of `key: value` pairs under a name, e.g. `dictionary: `.

```
book:
  title: War and Peace
  author: Leo Tolstoy
  year: 1869
```

Abbreviated form.

```
book: {title: War and Peace, author: Leo Tolstoy, year: 1869}
 ```

Dictionaries may contain lists too.

```
john:
  full_name: John Doe
  occupation: Developer
  skills:
    - front-end
    - back-end
    - databases
```

Abbreviated form.

```
john: { full_name: John Doe, occupation: Developer, skills: [front-end, back-end, databases]} 
```

#### Boolean values

Boolean values can be specified in many forms.

```
install_docker: true
use_password: FALSE
create_file: yes
```

#### Literal and single line
The pipe character `|` is used to define a literal text with multiple lines.

```
literal_text: |
  these lines
  will appear
  as you see it
```

The `>` character is used in making a very long line easier to read and edit.

```
single_line: >
  these lines
  will appear
  as a single line
  without line breaks 
```

## Modules and Tasks

#### Modules

Check the provided [documentation](https://docs.ansible.com/ansible/latest/user_guide/modules_intro.html).

Ansible comes with a huge number of [Modules](https://docs.ansible.com/ansible/2.9/modules/list_of_all_modules.html). There is also a [modules by category](https://docs.ansible.com/ansible/2.9/modules/modules_by_category.html) index.

The `ansible-doc` command displays Module documentation in the terminal.

```
ansible-doc yum  
```

A Module is a code or a binary unit that is copied and executed on each managed host in order to apply a Task.

#### Tasks

Each Task defines the Module it uses.

```
- name: reboot the servers  
  command: /sbin/reboot -t now  
```

In the above the `command` Module is used to reboot the servers specified in the `hosts` file.

#### Task name

A Task may omit the `name` keyword.

```
- command: /sbin/reboot -t now  
```

Ansible uses the `name` to report the Task being executed. So it is always a good idea to use a `name` with a Task.

#### Task arguments

A Module can take arguments.

```
- name: restart apache
  service:
    name: httpd
    state: restarted
```

In the above the `name: httpd` and the `state: restarted` are arguments.

Modules can be executed as ad-hoc commands from the command line, along with arguments.

```
ansible webservers -m command -a "/sbin/reboot -t now"
ansible webservers -m service -a "name=httpd state=started"
```

#### Return values

A Module returns a data structure that can be registered into a variable. There is a list of [common return values](https://docs.ansible.com/ansible/latest/reference_appendices/common_return_values.html) for all Modules, although a Module can have its own return values.

## Variables

Check the provided [documentation](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html)

Ansible uses Variables inside Playbooks. Ansible Variables act like variables in a programming language.

A valid Variable name may contain letters, numbers and underscores, while the first character cannot be a number.

Variables are defined in a Playbook, an Inventory, a Role, a File or at the command line.

Also a Variable may created during a Playbook run by registering the return value or values of a Task as a new Variable.

The following is a Variables file. The contents of a Variables file is a simple YAML dictionary. 

```
protocol: http
port: 8080
list: [one, two, three]
dict: { first_name: "John", last_name: "Doe" }
```

Next is a Playbook with Variables. It also shows the [Jinja2](https://en.wikipedia.org/wiki/Jinja_(template_engine)) syntax used in referencing a Variable.

```
- name: test playbook
  hosts: servers
  vars:
	protocol: http
	port: 8080
	list: [one, two, three]
	dict: { first_name: "John", last_name: "Doe" } 
  tasks:
    - name: print a message
      ansible.builtin.debug:
        msg: "{{ http }}"
```

> **NOTE**: Always quote values containing Variable references. The YAML parser may not be able to correctly interpret the syntax, since it would be a variable or it would be the start of a dictionary.

The following example shows how to include one or more Variable files into a Playbook.

```
- name: vars playbook
  hosts: servers
  vars:
	all_ok: true
  vars_files:
    - /path/to/vars/file1
    - /path/to/vars/file2 
  tasks:
	....
```

#### Load Variable files dynamically

Variable files can be loaded dynamically and conditionally by using the `include_vars` Module. Consult the [documentation](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/include_vars_module.html).

```
- name: vars playbook
  hosts: servers
  tasks:
    - name: include vars of a YAML file into the 'dynamic_vars' variable
      include_vars:
        file: /path/to/vars/file
        name: dynamic_vars
```

#### Referencing variables

Given the above Variable declarations the following is perfectly valid.

```
part: "{{ list[0] }}"
first_name: dict.first_name
first_name2: dict["first_name"]
```

#### Registering variables with the `register` keyword

The output of a Task can be assigned to a Variable using the `register` keyword. Then the Variable may be used in a later Task.

Variables created that way are host-level Variables. They are only valid on the **current managed host** for the rest of the current Playbook.

Here is an example.

```
- name: test playbook
  hosts: servers
  tasks:
    - name: capture output of a Task
      command: whoami
      register: login
    - name: display the registered Variable
      debug: var=login 
    - name: display login name
      debug: msg="Logged in as user {{ login.stdout }}"
```

#### Passing Variables at command line

```
# key=value notation
ansible-playbook playbook.yml --extra-vars "var1=value1 var2=value2"

# json notation
ansible-playbook playbook.yml --extra-vars '{"var1":"value1","var1":"value2"}'

# passing a YAML Variables file
ansible-playbook playbook.yml --extra-vars "@variables.yml"

# passing a JSON Variables file
ansible-playbook playbook.yml --extra-vars "@variables.json"

# passing multiple variable files
ansible-playbook playbook.yml --extra-vars=@vars_file1 --extra-vars=@vars_file2
```

> NOTE: The flag `--extra-vars` has the `-e` abbreviation.

```
ansible-playbook playbook.yml -e @vars_file
```


#### Force a Play to ask for a Variable value

The following Play will display the prompt `Enter the secret`, put the provided value to the `a_secret` variable and add a line with that value in the specified file, using the `lineinfile` module.

```
- name: test playbook
  hosts: servers
  vars_prompt:
    - name: a_secret
      prompt: Enter the secret
  tasks:
    - name: Add value to my-app-config.ini
      lineinfile:
        path: /etc/my-app-config.ini
        line: "SOME_ENTRY={{ a_secret }}"
```


#### Built-in Variables
Ansible defines a number of variables that are always available in a Playbook. Documentation refers to those Variables as [Special Variables](https://docs.ansible.com/ansible/latest/user_guide/playbooks_vars_facts.html#information-about-ansible-magic-variables).

Here is the [full list](https://docs.ansible.com/ansible/latest/reference_appendices/special_variables.html).


## Facts

Check the provided [documentation](https://docs.ansible.com/ansible/latest/user_guide/playbooks_vars_facts.html)

Ansible Facts is information regarding managed hosts. Ansible gathers those Facts from managed hosts when it begins to execute a Playbook. Facts is information regarding the operating system, NIC interfaces, IP addresses, CPUs, RAM, disks, etc.

When executing a Playbook, the first thing that happens is the gathering of Facts. After that Facts are accessible through the `ansible_facts` global variable.

The following command displays Facts of a specified managed host.

```
ansible IP_OR_HOSTNAME -m setup

# or
ansible all -m setup

# filter results
ansible all -m setup -a "filter=ansible_os_family"
```

The same result in a Playbook:

```
- name: display facts
  hosts: servers
  tasks:
    - name: display facts
      ansible.builtin.debug:
        var: ansible_facts
```

A real-world example is the following. This Playbook installs Apache web server based on Facts.

```
- name: install Apache
  hosts: servers
  tasks:
  - package:
      name: "httpd"
      state: present
    when ansible_facts["os_family"] == "RedHat"
  - package:
      name: "apache2"
      state: present
    when ansible_facts["os_family"] == "Debian"
```

#### Fact names
To access variables from Ansible Facts inside a Playbook, omit the `ansible_` prefix from the variable name. In the last example the full variable name is `ansible_os_family`, while inside the Playbook the `os_family` is used.

#### Fact data-types

Ansible Facts are stored in JSON format. A Fact variable data-type can be:
- List
- Dictionary
- Ansible Unsafe Text

##### List
Multiple values of homogenous information are stored in a List and they accessed using an array-like notation.
```
ansible_facts.all_ipv4_addresses[1]
ansible_facts.all_ipv4_addresses[2]

# or

ansible_facts["all_ipv4_addresses"][1]
ansible_facts["all_ipv4_addresses"][2]

```
##### Dictionary
Collections of key-value pairs are stored in a Dictionary and they accessed using the dot operator.

```
ansible_facts.default_ipv4.address
ansible_facts.memory_mb.real.free

# or

ansible_eth1['default_ipv4']['address']
ansible_eth1['memory_mb']['real']['free']
 
```

##### Ansible Unsafe Text
Simple values are stored in simple variables and they accessed using the variable name.

```
ansible_facts["architecture"]
```

#### Using `set_fact` to define a new Fact variable

The `set_fact` Module allows setting variables associated to the current host.

```
- name: facts playbook
  hosts: servers
  tasks:
    - name: set new facts
      set_fact: 
	  	ip4: {{ ansible_facts.default_ipv4.address }}
		list: [one, two, three]
		dict: { first_name: "John", last_name: "Doe" }
```

The above sets the Fact variable `ip4` to the default ipv4 address of the current managed host. It also sets two more Fact variables, a list and a dictionary.  

 
## Handlers
Check the provided [documentation](https://docs.ansible.com/ansible/latest/user_guide/playbooks_handlers.html).

A Handler is a special Task. It executes only when notified by a previous Task, which resulted in a "changed" status. If the status is not changed **the Handler is not called**.

For example, restart a service because of a configuration change, but avoid restarting it if the configuration is not changed. 

In the following example the Handler will be called **only** if the latest Apache is not found and needs to be installed.

```
- name: test playbook
  hosts: servers
  tasks:
    - name: install apache
      yum:
        name: httpd
        state: latest
      notify:
        - start apache
  handlers:
    - name: start apache
      service:
        name: httpd
        state: restarted    
```

The `notify` keyword accepts a list of Handler names, meaning multiple Handlers may be called by name, by the same Task.

> **NOTE**: Handlers run at the end of a Play after all the Tasks in a particular Play have been completed without failure.

There is the case where a Task notifies a Handler, but because a later Task fails, the Handler is not executed.

There are some ways to alter this behavior and force Handler execution:

- Use the `--force-handlers` command line option
- Add `force_handlers = True` to `ansible.cfg`
- Add `force_handlers: True` in a Play.


#### The `listen` keyword

A Handler is called by using its name.

Another alternative is instead of using the Handler name, to use a special verb. One or more Handlers listen for this verb and they are executed when it is called.

```
- name: listening handlers
  hosts: servers
  tasks:
    - name: notify handlers
      debug:
        msg: calling multiple handlers
      notify: "all handlers"
      changed_when: true
  handlers:
    - name: ping all
      ping:
      listen: "all handlers"
    - name: show a message
      debug:
        msg: message from a listening handler   
      listen: "all handlers"  
```

In the last example the `changed_when` keyword is used in order to force a state change. Again: if the status is not changed **the Handler is not called**.




## Tags
Check the provided [documentation](https://docs.ansible.com/ansible/latest/user_guide/playbooks_tags.html)

Tags are used in marking Plays, Blocks and Tasks. Tags then may be passed at the command line in order to execute only the marked Tasks.

The `tags` keyword used in defining a Tag or a list of Tags.

```
- name: tags
  hosts: servers
  tasks:
    - name: task 1
      debug:
        msg: message 1
      tags: one  
    - name: task 2
      ansible.builtin.debug:
        msg: message 2  
      tags:
        - one
        - two
```

Here is how to use Tags in command line:

```
ansible-playbook tags.yml --tags "one"

ansible-playbook tags.yml --tags "one, two"

# skip Tasks with that tag
ansible-playbook tags.yml --skip-tags "one"	
```



## Conditionals

Check the provided [documentation](https://docs.ansible.com/ansible/latest/user_guide/playbooks_conditionals.html)

Conditionals in Ansible are conditions that are evaluated before a Task is executed. When the condition is **not** met the Task is not executed.

#### The `when` keyword

The keyword `when` is used in defining conditions. A condition is an expression that may involve a Variable or a Fact.
 
Consider the following Playbook.

```
- name: A test play
  hosts: servers
  tasks:
  - name: get stats of a file
    ansible.builtin.stat:
      path: ~/temp.txt
    register: stat_result
  - name: error if file not found
    ansible.builtin.fail:
      msg: "File not found"
    when: stat_result.stat.exists == false
  - name: display stat result if file exists
    debug:
      var: stat_result  
    when: stat_result.stat.exists == true  
```

The first Task uses the [stat module](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/stat_module.html) to get information about a `~/temp.txt` file. The `stat` module retrieves Facts regarding a file, similar to the Linux [`stat` command](https://man7.org/linux/man-pages/man1/stat.1.html). The Task registers the result of the `stat` module to the `stat_result` Variable.

The second and the third Tasks use the `when` Conditional to check the existence of the `~/temp.txt` file. The second and the third Task will be executed only if its condition is met.

The third Task displays the full content of the `stat` result.

To test the above Playbook just create the `~/temp.txt` file in the managed hosts.

```
cd ~
touch ~/temp.txt
```
#### List of conditions and the `or` keyword

The `when`, and all the other Conditionals, may use a list of conditions. Conditions in a list are joined with `and`. The `or` may be used in joining multiple conditions in a single row.

```
- name: A test play
  hosts: ...
  tasks:
  - name: ...
    module: ...
    when:
      - condition 1
      - condition 2
      - (condition 3) or (condition 4)
``` 

#### The `changed_when` keyword

The `changed_when` Conditional keyword is used in defining when a particular Task has **changed** a managed host.

```
- name: A test play
  hosts: servers
  tasks:
  - name: Test Task
    command: /usr/bin/my-command -flag1 -flag2
    register: test_task_result
	changed_when: "'DONE' in test_task_result.stderr"
``` 


## Loops

Check the provided [documentation](https://docs.ansible.com/ansible/latest/user_guide/playbooks_loops.html)

A Loop in Ansible is a way to execute a Task multiple times.

The keywords `loop`, `until`, and `with_XXXX` are used with Loops.

### The `loop` keyword

The `loop` keyword loops over a list.

```
- name: A test play
  hosts: servers
  tasks:
  - name: create files
    file:
      path: "{{ item }}"
      state: touch
      mode: '660'
    loop:
      - ~/file1.txt
      - ~/file2.txt
```

The Task in the above Playbook uses the `file` [module](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/file_module.html) to create two files and set their permissions. For setting file permissions the symbolic mode can be used too, e.g. `u=rw,g=rw`. The paths of the two files are defined in a list of strings using the `loop` keyword.

The list introduced by the `loop` keyword could be a simple string list, or a list of dictionaries. Consider the following variation.

```
- name: A test play
  hosts: servers
  tasks:
  - name: create files
    file:
      path: "{{ item.path }}"
      mode: "{{ item.mode }}" 
      state: touch     
    loop:
      - { path: '~/file1.txt', mode: '600' }
      - { path: '~/file2.txt', mode: '660' }
```

##### The `loop_control` section

The `loop_control` section of a loop could be useful in many ways. 

The following example uses the keyword `pause` to introduce a 5 second delay between the three iterations of the loop. It also uses the keyword `index_var` to introduce an indexing variable.

```
- name: A test play
  hosts: servers
  tasks:
  - name: delay and indexing
    debug:
      msg: "Item: {{ item }}, Item Index: {{ i }}"    
    loop:
      - Ansible
      - is
      - great
    loop_control:
      pause: 5
      index_var: i
```

#### The `until` keyword

The `until` keyword is used in conjuction with the `retries` keyword. Using those keywords a Task will retry iterations until a certain condition is met. If not set, `retries` defaults to 1.

```
- name: A test play
  hosts: servers
  tasks:
  - name: retry something until a condition is met
    shell: do something here
    register: result
	until: result.stdout.find("text to find in result here") != -1
    retries: 5
    delay: 5
```
 

#### The `with_XXXX` keyword

The `with_list`, `with_items` and similar directives are still in use, but now they have been replaced by the `loop` keyword. Consult the documentation.


## Error handling

Check the provided [documentation](https://docs.ansible.com/ansible/latest/user_guide/playbooks_error_handling.html).

When a module fails or returns a non-zeor return code Ansible stops executing on that host and continues on other hosts. 

The `ignore_errors` directive allows execution to continue with the next Task on a host even in a case of a failure in a previous Task.

The `ignore_unreachable` directive ignores any error due to the host instance being unreachable.

```
- name: A test play
  hosts: servers
  tasks:
  - name: Fails always
    command: /bin/false
    ignore_errors: yes
	ignore_unreachable: yes
``` 

#### Non-zero return values

A non-zero return value means failure. But there are cases where the [`shell` module](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/shell_module.html) and the [`command` module](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/command_module.html) may return a non-zero value indicating success.

Here is a way to overcome this situation.

```
- name: A test play
  hosts: servers
  tasks:
  - name: Test Task
    shell: /usr/bin/foo || /bin/true        # in case when successful exit code is not zero
    ignore_errors: yes                      # another way to return success
``` 

#### The `failed_when` conditional directive
 
The `failed_when` conditional directive is used in defining a failure in a Task.

```
- name: A test play
  hosts: servers
  tasks:
  - name: Test Task
    command: /usr/bin/my-command -flag1 -flag2
    register: command_result
	failed_when: "'ERROR' in command_result.stderr"
``` 

The `failed_when` directive is a conditional. It may use a list of conditions or use the `or` keyword in a single condition.

#### The `any_errors_fatal` directive

The `any_errors_fatal` directive aborts Play execution if a fatal error occurs in any of the specified manage hosts.

```
- name: A test play
  hosts: servers
  any_errors_fatal: true
  tasks:
    ...
``` 

## Privilege escalation: become

Check the provided [documentation](https://docs.ansible.com/ansible/latest/user_guide/become.html)

Privilege escalation is used in order to execute one or more Tasks with a user, different from the one that logged into the Control host, with elevated permissions.

There are some directives that can be used in the Play or Task level.

- `become`: should be set to `yes` in order to activate privilege escalation.
- `become_user`: should be set to the user with the desired privileges, say `root`.
- `become_method`: shoud be set to the `become` method, say `sudo`.

```
- name: A test play
  hosts: servers
  become: yes
  become_user: root
  become_method: sudo
  tasks:
    ...
``` 

 ## Vault

Check the provided [documentation](https://docs.ansible.com/ansible/latest/user_guide/vault.html).

**Ansible Vault** encrypts files and variables thus protecting sensitive data such as passwords and keys, called `secrets`. 

#### Setting the Editor used by Vault

Ansible Vault uses the `vi` editor by default in editing Vault files. To change it to `nano` open your `~/.bashrc` file.

```
nano ~/.bashrc
```

Go to the end of the file and add the following line

```
export EDITOR=nano
```

Source the file for the canges to take effect.

```
. ~/.bashrc
```

Check the `EDITOR` variable, it should return `nano` now.

```
echo $EDITOR
```

### The `ansible-vault` command

The main Ansible Vault utility is the [`ansible-vault` command line tool](https://docs.ansible.com/ansible/latest/cli/ansible-vault.html).


The `ansible-vault`  command is used in creating encrypted files and then is used to view, edit, or decrypt the data.

The `ansible-vault create /path/to/secret/file` is used in creating an encrypted file. It will ask for password that will protect the new file and then it will open a text editor for the user to edit the protected file.

```
cd ~/Ansible
ansible-vault create ~/secrets1
```

Provide a password, add some content to the secret file and close the editor. Ansible Vault encrypts the file.

```
cat ~/secrets1
```

The `ansible-vault` is able to encrypt and existing un-encrypted file.

```
echo 'Ansible rules' > ~/secrets2
ansible-vault encrypt ~/secrets2
```

To view, edit or decrypt an encrypted file, the user has to provide the password used when the file was encrypted.

```
ansible-vault view ~/secrets1

ansible-vault edit ~/secrets1

ansible-vault decrypt ~/secrets1
```

It is possible to change the password of a file.

```
ansible-vault rekey ~/secrets1
```

### Prepare an encrypted file

Prepare an encrypted file. When the `nano` opens, just add a phrase to the file and save it. Ansible encrypts the file.

```
cd ~/Ansible
ansible-vault create ~/encrypted
```

### Passing the Vault password

Ansible commands, such as `ansible` and `ansible-playbook` use the password when decrypting Vault protected files. 

There are some ways to provide that password to those commands.

#### The `--ask-vault-pass` command line flag

Here is an example that will copy the encrypted file to all managed hosts and then it will decrypt it.

```
ansible all -m copy -a 'src=encrypted dest=/tmp/decrypted mode=0600 owner=root group=root' --ask-vault-pass -bK

```

The `-bK` flag will ask for the `sudo` password in order to become `root` user in the remote managed host. You'll be asked for two passwords: the remote `sudo` and the Ansible Vault password.

```
BECOME password: 
Vault password: 
```
#### The `--vault-password-file` command line flag

Create an un-encrypted file with your password.

```
echo 'my_password' > psw_file
```

And then pass that password file to Ansible. Ansible will not ask for a Vault password this time.

```
ansible all -m copy -a 'src=encrypted dest=/tmp/decrypted mode=0600 owner=root group=root' --vault-password-file=psw_file -bK
```

#### The `ANSIBLE_VAULT_PASSWORD_FILE` environment variable

Use the `ANSIBLE_VAULT_PASSWORD_FILE` environment variable. Again Ansible will not ask for a Vault password.

```
export ANSIBLE_VAULT_PASSWORD_FILE=psw_file
ansible all -m copy -a 'src=encrypted dest=/tmp/decrypted mode=0600 owner=root group=root' -bK
```

#### Add a `vault_password_file` entry to `ansible.cfg`

Edit `ansible.cfg` with `nano` and add the `vault_password_file` entry.

```
[defaults]
. . .
vault_password_file = psw_file
```

### Encrypted Variable files

Consider a plain Variables file, say `vars.yml`.

```
var1: value1
var2: value2
```

You then may encrypt the variable file.

```
ansible-vault encrypt vars.yml
```

And then pass that file when executing the Playbook.

```
ansible-playbook playbook.yml --extra-vars "@vars.yml"
```

Or use the `vars_files` directive in a Play.

```
- name: A test play
  hosts: servers
  vars_files:  
    - /path/to/vars.yml
  tasks:
    ...
```

In both cases Ansible will decrypt the file and use its content.

## Further reading

Ansible is a vast subject. This text just scratches the surface. Here are some links to other parts of Ansible that you may find useful to know.

- [Roles](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html)
- [Collections](https://docs.ansible.com/ansible/latest/user_guide/collections_using.html)
- [Blocks](https://docs.ansible.com/ansible/latest/user_guide/playbooks_blocks.html)
- [Templates](https://docs.ansible.com/ansible/latest/user_guide/playbooks_templating.html)
- [Tests](https://docs.ansible.com/ansible/latest/user_guide/playbooks_tests.html)
- [Patterns](https://docs.ansible.com/ansible/latest/user_guide/intro_patterns.html)
- [Lookups](https://docs.ansible.com/ansible/latest/user_guide/playbooks_lookups.html)

## A summary

```

- hosts: all
  # remote_user: root             # User used to log into the target via the connection plugin. You may login as this user and then "become" someone else
  become: yes                     # Boolean that controls if privilege escalation is used or not on Task execution.
  become_user: root               # User that you ‘become’ after using privilege escalation. The remote/login user must have permissions to become this user.
  become_method: sudo
  # gather_facts: no
  # any_errors_fatal: true        # aborts playbook execution if a fatal error occurs in any of the specified hosts

  ##########################################
  # Variables - Varialbe Referene: https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html
  ##########################################

  # inline variables
  vars:
    var1: value1
    var2: value2

  # variables in external files    
  vars_files:                     # a list of one or more variable files
    - /path/to/var/file1 
    - /path/to/var/file2
# variable files format
# var1: value1
# var2: value2     
 
# variables can also be passed in the command line, e.g.
#   ansible-playbook my_playbook.yml --extra-vars "var1=value1 var2=value2"
 
# There is also the include_vars modules which can be used to load
# variables from a single file or a directory
# SEE: https://docs.ansible.com/ansible/latest/modules/include_vars_module.html

  ##########################################
  # Some useful modules - Module Reference: https://docs.ansible.com/ansible/latest/modules/list_of_all_modules.html
  ##########################################
  tasks:
  # yum - https://docs.ansible.com/ansible/latest/modules/yum_module.html
  - name: the yum module executes yum commands. This example ensures apache is at the latest version
    yum:                       
      name: httpd
      state: latest

  # service - https://docs.ansible.com/ansible/latest/modules/service_module.html
  - name: The service module controls services on remote hosts. Supported init systems include BSD init, OpenRC, SysV, Solaris SMF, systemd, upstart. This example ensures that apache is running
    service:
      name: httpd
      state: started      

  - name: Restart network service for interface eth0
    service:
      name: network
      state: restarted
      args: eth0      
  
  # file - https://docs.ansible.com/ansible/latest/modules/file_module.html
  - name: the file module sets attributes of files, symlinks, and directories, or removes files/symlinks/directories. Many other modules support the same options as the file module - including copy, template, and assemble.
    file:                      
      path: /etc/{{ some_variable_here }}.conf
      owner: foo
      group: foo    
      mode: 0644                          # when specifying mode using octal numbers, add a leading 0

  # copy - https://docs.ansible.com/ansible/latest/modules/copy_module.html
  - name: the copy module copies a file from the local or remote machine to a location on the remote machine. Example copying file with owner and permissions
    copy:
      src: /srv/myfiles/foo.conf
      dest: /etc/foo.conf
      owner: "{{ some_variable_here }}" # YAML syntax requires that if you start a value with {{ foo }} you quote the whole line, since it wants to be sure you aren’t trying to start a YAML dictionary. 
      group: foo
      mode: 0644
      remote_src: no                    # If no (the default), it will search for src at originating/manager machine. If yes it will go to the remote/target machine for the src. Default is no.

  # command - https://docs.ansible.com/ansible/latest/modules/command_module.html
  - name: The command module takes the command name followed by a list of space-delimited arguments. It is NOT executed through the shell, so variables like $HOME and operations like "<", ">", "|", ";" and "&" will not work. This example returns motd to registered var
    command: cat /etc/motd
    register: mymotd                    # "registers" a variable as a result of this task. Results will vary from module to module. Use of -v when executing playbooks will show possible values for the results.

  - name: Another example of the command module. It runs the command ONLY if the specified file does not exist.
    command: /usr/bin/make_database.sh arg1 arg2 || /bin/true        # in case when successful exit code is not zero
    args:
      creates: /path/to/database        # the "creates" section gets a filename or (since 2.0) glob pattern. If it already exists, this step won't be run. It makes the task indepotent

  - name: This example executes a script
    command: sh /home/test_user/test.sh      

  # script - https://docs.ansible.com/ansible/latest/modules/script_module.html
  - name: Runs a local script on a remote node after transferring it. The script will be processed through the shell environment. This example runs a script only if file.txt exists on the remote node
    script: /some/local/remove_file.sh --some-argument 1234
    chdir: /a/path/on/the/remote/machine    # Change into this directory on the remote node before running the script.
    args:
      removes: /the/removed/file.txt        # A filename on the remote node, when it does not exist, this step will not be run. Makes the task indepotent

  # shell - https://docs.ansible.com/ansible/latest/modules/shell_module.html
  - name: The shell module takes the command name followed by a list of space-delimited arguments. It is almost exactly like the command module but runs the command through a shell (/bin/sh) on the remote node.
    shell: /usr/bin/foo || /bin/true        # in case when successful exit code is not zero
    register: foo_result                    # registers a variable to be used in the next example
    ignore_errors: yes                      # another way to return success

  - name: Executes ONLY if the foo_result result variable of the previous example equals to 5
    shell: /usr/bin/bar
    when: foo_result.rc == 5                # SEE: Conditionals, link: https://docs.ansible.com/ansible/latest/user_guide/playbooks_conditionals.html

  - name: The shell module may have multiple lines
    shell: |
      do this
      do that
      do something else
      exit 0

  # template - https://docs.ansible.com/ansible/latest/modules/template_module.html
  - name: The template module gets a source file from the local machine, passes it through the Jinja2 template engine, and copies it to the remote hosts. Link: https://blog.knoldus.com/ansible-playbook-using-templates/     
    template:
      src: /mytemplates/foo.j2
      dest: /etc/file.conf
      owner: bin
      group: wheel
      mode: 0644
      force: yes                            # the default is yes, which will replace the remote file when contents are different than the source. If no, the file will only be transferred if the destination does not exist.

  # slack - https://docs.ansible.com/ansible/latest/modules/slack_module.html
  - name: The slack module sends notification message via Slack  
    slack:
      token: thetoken/generatedby/slack
      msg: 'Megale skisame'
      channel: '#ansible'
     delegate_to: localhost

  # mail - https://docs.ansible.com/ansible/latest/modules/mail_module.html
  - name: The mail module sends emails
    mail:
      host: smtp.gmail.com
      port: 587
      username: username@gmail.com
      password: mysecret
      to: John Smith <john.smith@example.com>
      subject: Ansible-report
      body: This is the body
    delegate_to: localhost     
```

 
 

 


