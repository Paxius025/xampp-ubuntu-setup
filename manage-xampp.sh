#!/bin/bash

# Function to check sudo status
check_sudo() {
    sudo -n true 2>/dev/null
    if [ $? -eq 0 ]; then
        return 0 # Sudo is available without password
    else
        return 1 # Sudo needs a password
    fi
}

# Ensure sudo privileges
if check_sudo; then
    echo "Sudo access is already available. ✅"
else
    echo "Please enter your sudo password to continue... 🔑"
    sudo -v
    if [ $? -ne 0 ]; then
        echo "Invalid sudo password. Exiting script. ❌"
        exit 1
    fi
fi

# Ask if the user wants to skip stopping services and reloading systemd
read -p "Do you want to skip stopping services and reloading systemd? (y/n): " skip_choice

if [[ "$skip_choice" =~ ^[Yy]$ ]]; then
    echo "Skipping stopping services and reloading systemd. ⏩"
else
    # Reload systemd to prevent warnings
    echo "Reloading systemd daemon to ensure up-to-date service configurations... 🔄"
    sudo systemctl daemon-reload

    sleep 1

    # Function to stop a service
    stop_service() {
        local service_name=$1
        echo "Stopping $service_name... 🛑"
        sudo systemctl stop "$service_name"
    }

    # Stop services
    stop_service "apache2"
    stop_service "mysql"

    # Delay for better user feedback
    echo "Waiting a second before starting XAMPP manager... ⏳"
    sleep 1.5
fi

# Start XAMPP manager
echo "Starting XAMPP manager... 🚀"
sudo /opt/lampp/manager-linux-x64.run

# Final message
echo "XAMPP is now running! If you encounter issues, try restarting all services using the command: 'sudo systemctl restart apache2 mysql'. 🔄"

