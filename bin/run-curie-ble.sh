DEVICE_ID_0="84:68:3E:00:F3:AC"
DEVICE_ID_1="84:68:3E:00:F3:BF"
#DEVICE_ID_2="84:68:3E:00:F3:C2"

EXEC="python curie_ble.py -d"
FAKE="python fake_ble_data.py"

while true; do
    echo "Running '$EXEC $DEVICE_ID_0' ..."
    $EXEC $DEVICE_ID_0
    echo "Server '$EXEC $DEVICE_ID_0' exited with exit code $?."
    echo "Running '$EXEC $DEVICE_ID_1' ..."
    $EXEC $DEVICE_ID_1
    echo "Server '$EXEC $DEVICE_ID_1' exited with exit code $?."
    echo "Running '$EXEC $DEVICE_ID_2' ..."
    $EXEC $DEVICE_ID_2
    echo "Server '$EXEC $DEVICE_ID_2' exited with exit code $?."
    echo "Running '$FAKE' ..."
    $FAKE
    echo "Server '$FAKE' done with code $?."
    sleep 1
done
