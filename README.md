# TERRAFORM project
# Docker and Permissions Setup 

## Steps to Run Commands

1. **Add User to Docker Group:**

   To allow your user to run Docker commands without `sudo`, run the following commands:

   ```sh
   sudo usermod -aG docker $USER
   newgrp docker


2. **Add permisions:** 


    ```sh
   sudo visudo
