## Overview of MySQL Programs

- mysqld
    mysql server program , use mysqld -v --help to see all the options 
    
- mysqld_safe
    mysqld_safe tries to start an executable named mysqld
    mysqld_safe reads all options from the [mysqld], [server], and [mysqld_safe] sections in option files.
    
- mysql.server
    which starts the MySQL server using mysqld_safe.    
    ```sh 
     cp mysql.server /etc/init.d/mysql
     chmod +x /etc/init.d/mysql
     chkconfig --add mysql
     #On some Linux systems, the following command also seems to be necessary to fully enable the mysql script:
     chkconfig --level 345 mysql on
    ```
    
- mysql_multi
    A server startup script that can start or stop multiple servers installed on the system. 
    
- mysql 
    mysql client
    SSL (Secure Sockets Layer) is a standard security protocol for establishing encrypted links 
    between a web server and a browser in an online communication. 
    

- mysqladmin 
    A client that performs administrative operations, such as creating or dropping databases, reloading the grant tables, 
    flushing tables to disk, and reopening log files. mysqladmin can also be used to retrieve version, process, and status information from the server
    
- mysqlcheck 
    A table-maintenance client that checks, repairs, analyzes, and optimizes tables.
    
- mysqldump
    Command :
    ```sh 
    mysqldump -p --all-databases > all_databases.sql
    mysqldump -p --databases mysql > mysql.sql
    ```
- mysqlpump
    mysqlpump uses MySQL features introduced in MySQL 5.7, and thus assumes use with MySQL 5.7 or higher.
    
    
    
    
    
    
    
    
