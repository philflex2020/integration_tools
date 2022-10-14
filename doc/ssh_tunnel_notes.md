ssh tunnel notes


ssh -L 3336:db001.host:3306 user@pub001.host
Copy
Once you run the command, you’ll be prompted to enter the remote SSH user password. Once entered, you will be logged into the remote server, and the SSH tunnel will be established. It is also a good idea to set up an SSH key-based authentication and connect to the server without entering a password.

Now, if you point your local machine database client to 127.0.0.1:3336, the connection will be forwarded to the db001.host:3306 MySQL server through the pub001.host machine that acts as an intermediate server.

You can forward multiple ports to multiple destinations in a single ssh command. For example, you have another MySQL database server running on machine db002.host, and you want to connect to both servers from your local client, you would run:

ssh -L 3336:db001.host:3306 3337:db002.host:3306 user@pub001.host
Copy
To connect to the second server, you would use 127.0.0.1:3337.