#sudo timeout -s SIGINT 5s hcitool -i hci0 lescan | grep -i seesaw > ble-dev.txt
sudo timeout -s SIGINT 5s hcitool -i hci0 lescan | grep -i seesaw

